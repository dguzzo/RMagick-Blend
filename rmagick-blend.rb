### TODO: there is a major memory leak somewhere, possibly in the RMagick read() or write() functions. running even a few
### cycles of compositing on ~3-4MB files will quickly chew up 1.5GB of RAM, which isn't free'd until irb is quit.
###  this memory is of course freed when the program finishes when run directly with the 'ruby' command

require 'RMagick'
require './lib/utils'
require 'pp'
require 'yaml'

$BatchesRun = 0
NUM_FILES_BEFORE_WARN =  40

def image_compositing_sample(options={})
    defaults = {
        num_operations: 5, 
        append_operation_to_filename: false, 
        shuffle_composite_operations: false,
        directories: { output_dir: 'images/image-composites' },
        file_format: 'jpg',
        save_history: true
    }
    
    options = defaults.merge(options)
    
    src, dst = options[:directories] ? get_image_pair_via_directories(options[:directories]) : get_image_pair
    newCompositeArray = Magick::CompositeOperator.values.shuffle if options[:shuffle_composite_operations]
    # first two CompositeOperator are basically no-ops, so skip 'em
    range = options[:shuffle_composite_operations] ? 0...options[:num_operations] : 2...(options[:num_operations]+2)
    output_dir = Utils::createDirIfNeeded(options[:directories][:output_dir])
    
    puts "beginning composites processing, using #{options[:num_operations]} different operations"
    
    newCompositeArray[range].each_with_index do |composite_style, index|
        puts "#{(index.to_f/options[:num_operations]*100).round}%"
        append_string = options[:append_operation_to_filename] ? composite_style.to_s : index
        result = dst.composite(src, 0, 0, composite_style)
        result.write("./#{output_dir}/#{pretty_file_name(dst)}--#{pretty_file_name(src)}--#{append_string}.#{options[:file_format]}")
    end
    
    save_history(src: src, dst: dst, options: options) if options[:save_history]
    
    $BatchesRun += 1
    puts Utils::ColorPrint::green("\ndone!")
end

def pretty_file_name(image_file)
    extension_regex = /\.jpg$/i
    filename_regex = /\/(\w*)$/i
    image_file.filename.gsub(extension_regex, '').match(filename_regex)[1]
end

def save_history(args)
    src_name = args[:src].filename.force_encoding("UTF-8")
    dst_name = args[:dst].filename.force_encoding("UTF-8")
    save_path = "#{args[:options][:directories][:output_dir]}/previous_batch.yml"

    puts "writing history file: #{save_path}"
    File.open(save_path, 'w') do |file|
        values = { src_name: src_name, dst_name: dst_name, options: args[:options] }
        file.write(values.to_yaml)
    end
    
    rescue => e
        msg = Utils::ColorPrint::green("error in save_history #{e.message}")
        puts msg
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

def open_files_at_end?(force = false, suppress = false)
    return if suppress
    
    unless force
        puts "\ndo you want to open the files in Preview? #{Utils::ColorPrint::green('y/n')}"
        open_photos_at_end = !!(gets.chomp).match(/^(y|yes)/)
    end
  
      if force || open_photos_at_end
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

$output_dir = "images/minimal-output"
$file_format = 'bmp'

start_time = Time.now
1.times do 
    image_compositing_sample(
        num_operations: 3, 
        directories: { source: "images/minimal-source", destination: "images/minimal-destination", output_dir: $output_dir },
        append_operation_to_filename: true, 
        shuffle_composite_operations: true,
        file_format: $file_format
    )
end
    
end_time = Time.now
puts "BatchesRun: #{$BatchesRun} in #{end_time-start_time} seconds."
open_files_at_end?(false, true)

