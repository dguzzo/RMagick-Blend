### TODO: there is a major memory leak somewhere, possibly in the RMagick read() or write() functions. running even a few
### cycles of compositing on ~3-4MB files will quickly chew up 1.5GB of RAM, which isn't free'd until irb is quit.
###  this memory is of course freed when the program finishes when run directly with the 'ruby' command

require 'RMagick'
require './lib/utils'
require 'pp'
require 'yaml'
require 'optparse'
require 'pry'
require 'pry-nav'

$BatchesRun = 0
NUM_FILES_BEFORE_WARN =  40
$optimized_num_operation_large = 16
OPTIMIZED_NUM_OPERATION_SMALL = 8
$output_dir = "images/batch-3-output"
$file_format = 'bmp'
$flags = {}
$specific_comps_to_run = nil
$COPY_COMPS = %w(CopyBlackCompositeOp CopyBlueCompositeOp CopyCompositeOp CopyCyanCompositeOp CopyGreenCompositeOp CopyMagentaCompositeOp CopyOpacityCompositeOp CopyRedCompositeOp CopyYellowCompositeOp)
$SET1_COMPS = %w(BlendCompositeOp HardLightCompositeOp)
# $specific_comps_to_run = $COPY_COMPS

OptionParser.new do |opts|
  opts.banner = "Usage: rmagick-blend.rb [options]"

  opts.on('-o', '--operations NUM', "number of blend operations to run [default is #{OPTIMIZED_NUM_OPERATION_SMALL}]") { |v| $flags[:num_operations] = v }
  opts.on('-p', '--profile', "show timing profile debug info") { |v| $flags[:perf_profile] = v }
  opts.on('-s', '--swap', "swap the destination image and the source image") { |v| $flags[:switch_src_dest] = v }
  opts.on('-j', '--jpeg', "use jpg instead of bmp for composite output file") do 
      $file_format = "jpg"
      $optimized_num_operation_large += 10
  end
  opts.on('-h', '--help', 'Prints out this very help guide of options. yes, this one.') do |v| 
      $flags[:help] = v 
      puts "\n#{opts}"
      exit
  end
  # opts.on('-p', '--sourceport PORT', 'Source port') { |v| $flags[:source_port] = v }

end.parse!

# puts "YOUVE ACHEIVED HELP!\n #{$flags}" if $flags[:help]

def image_compositing_sample(options={})
    defaults = {
        num_operations: OPTIMIZED_NUM_OPERATION_SMALL, 
        append_operation_to_filename: false, 
        shuffle_composite_operations: false,
        directories: { output_dir: 'images/image-composites' },
        file_format: 'jpg',
        save_history: true,
        use_history: false,
        switch_src_dest: false
    }
    
    options = defaults.merge(options)
    options[:num_operations] = $flags[:num_operations].to_i if $flags[:num_operations]
    options[:switch_src_dest] = $flags[:switch_src_dest] if $flags[:switch_src_dest]
    
    if options[:use_history]
        src, dst = get_image_pair_from_history(options)
    else
        src, dst = options[:directories] ? get_image_pair_via_directories(options[:directories]) : get_image_pair
    end

    if options[:switch_src_dest]
        puts "swapping source and destination files..."
        temp = src
        src = dst
        dst = temp
    end
    
    compositeArray = options[:shuffle_composite_operations] ? Magick::CompositeOperator.values.shuffle : Magick::CompositeOperator.values
    
    if $specific_comps_to_run
        range = 0...compositeArray.length
        options[:num_operations] = $specific_comps_to_run.length
    else
        # first two CompositeOperator are basically no-ops, so skip 'em. also, don't go out of bounds with the index
        range = 2...[options[:num_operations] + 2, Magick::CompositeOperator.values.length].min
    end
    
    output_dir = Utils::createDirIfNeeded(options[:directories][:output_dir])
    
    puts "\nbeginning composites processing, using #{Utils::ColorPrint::green(options[:num_operations])} different operations"
    
    compositeArray[range].each_with_index do |composite_style, index|
        next if $specific_comps_to_run && !$specific_comps_to_run.include?(composite_style.to_s)
        
        puts "#{(index.to_f/options[:num_operations]*100).round}%" unless $specific_comps_to_run
        puts "#{Utils::ColorPrint::green(composite_style.to_s)}"
        append_string = options[:append_operation_to_filename] ? composite_style.to_s : index
        start_time = Time.now
        result = dst.composite(src, 0, 0, composite_style)
        end_time = Time.now
        puts "PERF PROFILING .composite(): #{Utils::ColorPrint::yellow(end_time-start_time)} seconds." if $flags[:perf_profile]

        start_time = Time.now
        result.write("./#{output_dir}/#{pretty_file_name(dst)}--#{pretty_file_name(src)}--#{append_string}.#{options[:file_format]}")
        end_time = Time.now
        puts "PERF PROFILING .write(): #{Utils::ColorPrint::yellow(end_time-start_time)} seconds." if $flags[:perf_profile]
    end
    
    save_history(src: src, dst: dst, options: options) if options[:save_history]
    
    $BatchesRun += 1
    puts Utils::ColorPrint::green("\ndone!")
end

def pretty_file_name(image_file)
    extension_regex = /\.jpg$/i
    filename_regex = /\/([^\/]*)$/i
    begin
        image_file.filename.gsub(extension_regex, '').match(filename_regex)[1]
    rescue
        "improper-filename-#{Time.now.asctime}"
    end
end

def save_history(args)
    src_name, dst_name = [ args[:src], args[:dst] ].map{ |file| file.filename.force_encoding("UTF-8") }
    save_path = "#{args[:options][:directories][:output_dir]}/previous_batch.yml"

    puts "writing history file: #{save_path}"
    File.open(save_path, 'w') do |file|
        values = { src_name: src_name, dst_name: dst_name, options: args[:options] }
        file.write(values.to_yaml)
    end
    
    rescue => e
        puts Utils::ColorPrint::green("error in save_history #{e.message}")
end

# TODO: refactor this all within get_image_pair()
def get_image_pair_via_directories(directories)
    source_images = Dir.entries(directories[:source]).keep_if{|i| i =~ /\.jpg$/i}
    raise "need at least one source image in #{directories[:source]} to begin!" if source_images.length < 1
    destination_images = Dir.entries(directories[:destination]).keep_if{|i| i =~ /\.jpg$/i}
    raise "need at least one destination image in #{directories[:destination]} to begin!" if source_images.length < 1

    destination_name = destination_images.shuffle!.sample
    source_name = source_images.shuffle!.sample
    source = Magick::Image.read("./#{directories[:source]}/#{source_name}").first
    destination = Magick::Image.read("./#{directories[:destination]}/#{destination_name}").first
    
    return [source, destination]
end


def get_image_pair
    images = Dir.entries("images").keep_if{|i| i =~ /\.jpg$/i}
    raise "need at least two images to begin!" if images.length < 2

    destination_name = images.shuffle!.sample
    images.delete(destination_name)
    source_name = images.sample
    source = Magick::Image.read("./images/#{source_name}").first
    destination = Magick::Image.read("./images/#{destination_name}").first
    
    return [source, destination]
end

def get_image_pair_from_history(options)
    
    begin
        file_path = "#{options[:directories][:output_dir]}/previous_batch.yml"
        raise "Can't find #{file_path}; exiting." unless File.exists?(file_path) # don't rescue, cuz not sure how i want the program to fail gracefully yet
    rescue => e
        puts Utils::ColorPrint.red(e.message)
        exit
    end
    
    history = File.read(file_path)
    history_hash = YAML.load(history)
    source = history_hash[:src_name]
    destination = history_hash[:dst_name]

    puts "loading source: #{Utils::ColorPrint::yellow( source )}"
    puts "loading destination: #{Utils::ColorPrint::yellow( destination )}"

    source = Magick::Image.read(source).first
    destination = Magick::Image.read(destination).first

    return [source, destination]
end

def open_files_at_end?(options = {})
    options = { force: false, suppress: false }.merge(options)
    
    return if options[:suppress]
    
    unless options[:force]
        puts "\ndo you want to open the files in Preview? #{Utils::ColorPrint::green('y/n')}"
        open_photos_at_end = !!(gets.chomp).match(/^(y|yes)/)
    end
  
      if options[:force] || open_photos_at_end
          Dir.chdir($output_dir)
          
          num_files_created = Dir.entries(Dir.pwd).keep_if{ |i| i =~ /\.#{$file_format}$/i }.length
          
          if num_files_created > NUM_FILES_BEFORE_WARN
              puts "\n#{num_files_created} files were generated; opening them all could cause the system to hang. proceed? #{Utils::ColorPrint::yellow('y/n')}"
              open_many_files = !!(gets.chomp).match(/^(y|yes)/)
              return unless open_many_files
          end
          
          `open *.#{$file_format}`
      end
end


###
def run_batch
    
    options = {
        directories: { source: "images/batch-3-source", destination: "images/batch-3-destination", output_dir: $output_dir },
        append_operation_to_filename: true, 
        shuffle_composite_operations: true,
        file_format: $file_format,
        switch_src_dest: false, # todo: make this a bool from user input
    }

    puts "\ndo you want to pursue the previous images in depth? #{Utils::ColorPrint::green('y/n')}"
    user_input = gets.strip
    large_batch = !!(user_input =~ /^(y|yes)/) || user_input.empty?

    if large_batch
        options.merge!({
            num_operations: $optimized_num_operation_large,
            use_history: true
        })
        puts "running large batch using history file"
    end

    start_time = Time.now
    1.times do 
        image_compositing_sample(options)
    end

    end_time = Time.now
    puts "BatchesRun: #{$BatchesRun} in #{Utils::ColorPrint::green(end_time-start_time)} seconds."
    open_files_at_end?(force: true, suppress: false)
    
end

run_batch
