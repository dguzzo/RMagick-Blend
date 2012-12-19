### TODO: there is a major memory leak somewhere, possibly in the RMagick read() or write() functions. running even a few
### cycles of compositing on ~3-4MB files will quickly chew up 1.5GB of RAM, which isn't free'd until irb is quit.
###  this memory is of course freed when the program finishes when run directly with the 'ruby' command

require 'RMagick'
require './lib/utils'
require './lib/colorprint'
require 'pp'

$BatchesRun = 0

def image_compositing_sample(options={})
    defaults = {
        num_operations: 5, 
        append_operation_to_filename: false, 
        shuffle_composite_operations: false,
        directories: { output_dir: 'images/image-composites' },
        file_format: 'jpg'
    }
    
    options = defaults.merge(options)
    
    src, dst = options[:directories] ? get_image_pair_via_directories(options[:directories]) : get_image_pair
    
    newCompositeArray = Magick::CompositeOperator.values.shuffle if options[:shuffle_composite_operations]
    # first two CompositeOperator are basically no-ops, so skip 'em
    range = options[:shuffle_composite_operations] ? 0...options[:num_operations] : 2...(options[:num_operations]+2)
    output_dir = Utils::createDirIfNeeded(options[:directories][:output_dir])
    
    puts "beginning composites processing, using #{options[:num_operations]} different operations"
    newCompositeArray[range].each_with_index do |composite_style, index|
        # print '.'
        puts "#{(index.to_f/options[:num_operations]*100).round}%"
        append_string = options[:append_operation_to_filename] ? composite_style.to_s : index
        result = dst.composite(src, 0, 0, composite_style)
        extension_regex = /\.jpg$/i
        filename_regex = /\/(\w*)$/i
        # TODO refactor via a method
        destination_filename = dst.filename.gsub(extension_regex, '').match(filename_regex)[1]
        source_filename = src.filename.gsub(extension_regex, '').match(filename_regex)[1]
        
        result.write("./#{output_dir}/#{destination_filename}--#{source_filename}--#{append_string}.#{options[:file_format]}")
    end
    puts "\ndone!"
    $BatchesRun += 1
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
    # dst_name = "circle works-it could go on forever.jpg"
    # src_name = "day rise over the fort.jpg"

    destination_name = images.shuffle!.sample
    images.delete(destination_name)
    source_name = images.sample
    source = Magick::Image.read("./images/#{source_name}").first
    destination = Magick::Image.read("./images/#{destination_name}").first
    
    return [source, destination]
end

def open_files_at_end?(force = false)
    unless force
        puts "\ndo you want to open the files in Preview? #{ColorPrint::green('y/n')}"
        open_photos_at_end = !!(gets.chomp).match(/^(y|yes)/)
    end
  
      if force || open_photos_at_end
          Dir.chdir($output_dir)
          `open *.#{$file_format}`
      end
end

$output_dir = "images/minimal-output"
$file_format = 'bmp'

start_time = Time.now
1.times do 
    image_compositing_sample(
        num_operations: 14, 
        directories: { source: "images/minimal-source", destination: "images/minimal-destination", output_dir: $output_dir },
        append_operation_to_filename: true, 
        shuffle_composite_operations: true,
        file_format: $file_format
    )
end
    
end_time = Time.now
puts "BatchesRun: #{$BatchesRun} in #{end_time-start_time} seconds."
open_files_at_end?(true)

