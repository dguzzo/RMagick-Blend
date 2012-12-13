### TODO: there is a major memory leak somewhere, possibly in the RMagick read() or write() functions. running even a few
### cycles of compositing on ~3-4MB files will quickly chew up 1.5GB of RAM, which isn't free'd until irb is quit.
###  this memory is of course freed when the program finishes when run directly with the 'ruby' command

require 'RMagick'
require './lib/utils'
require 'pp'

$BatchesRun = 0

def gradient_compositing_sample
    gold_fill = Magick::GradientFill.new(0, 0, 0, 0, "#f6e09a", "#cd9245")
    red_fill = Magick::GradientFill.new(0, 0, 0, 0, "#ff0000", "#ff8888")

    dst = Magick::Image.new(128, 128, gold_fill)
    src = Magick::Image.new(128, 128, red_fill)
    #src = Magick::Image.read("composite1-src.gif")[0]
    output_dir = Utils::createDirIfNeeded('images')
    
    # result = dst.composite(src, Magick::CenterGravity, Magick::OverCompositeOp)
    # result = dst.composite(src, 0, 0, Magick::OverCompositeOp)
    # result.write('./images/composites/composite1.gif')


    print "\nbeginning composites processing"
    Magick::CompositeOperator.values.each_with_index do |composite_style, index|
        print '.'
        result = dst.composite(src, 0, 0, composite_style)
        result.write("./#{output_dir}/gradient-composites/composite#{index}.gif")
    end
    puts "\ndone!"
end

def image_compositing_sample(options={})
    defaults = {
        num_operations: 5, 
        append_op_to_filename: false, 
        shuffle_composite_operations: false
    }
    
    options = defaults.merge(options)
    
    src, dst = options[:directories] ? get_image_pair_via_directories(options[:directories]) : get_image_pair
    
    newCompositeArray = Magick::CompositeOperator.values.shuffle if options[:shuffle_composite_operations]
    # first two CompositeOperator are basically no-ops, so skip 'em
    range = options[:shuffle_composite_operations] ? 0...options[:num_operations] : 2...(options[:num_operations]+2)
    output_dir = Utils::createDirIfNeeded('images/image-composites')
    
    puts "beginning composites processing, using #{options[:num_operations]} different operations"
    newCompositeArray[range].each_with_index do |composite_style, index|
        print '.'
        append_string = options[:append_op_to_filename] ? composite_style.to_s : index
        result = dst.composite(src, 0, 0, composite_style)
        extension_regex = /\.jpg$/i
        filename_regex = /\/(\w*)$/i
        # TODO refactor via a method
        destination_filename = dst.filename.gsub(extension_regex, '').match(filename_regex)[1]
        source_filename = src.filename.gsub(extension_regex, '').match(filename_regex)[1]
        
        result.write("./#{output_dir}/#{destination_filename}--#{source_filename}--#{append_string}.jpg")
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

start_time = Time.now
# gradient_compositing_sample
1.times do 
    image_compositing_sample(
        num_operations: 26, 
        directories: { source: "images/portraits_source", destination: "images/portraits_destination" },
        append_op_to_filename: true, 
        shuffle_composite_operations: true
    )
end
    
end_time = Time.now
puts "BatchesRun: #{$BatchesRun} in #{end_time-start_time} seconds."