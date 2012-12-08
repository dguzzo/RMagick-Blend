### TODO: there is a major memory leak somewhere, possibly in the RMagick read() or write() functions. running even a few
### cycles of compositing on ~3-4MB files will quickly chew up 1.5GB of RAM, which isn't free'd until irb is quit.
###  this memory is of course freed when the program finishes when run directly with the 'ruby' command

require 'RMagick'
require './lib/utils'

$BatchesRun = 0

def gradient_compositing_sample
    gold_fill = Magick::GradientFill.new(0, 0, 0, 0, "#f6e09a", "#cd9245")
    red_fill = Magick::GradientFill.new(0, 0, 0, 0, "#ff0000", "#ff8888")

    dst = Magick::Image.new(128, 128, gold_fill)
    src = Magick::Image.new(128, 128, red_fill)
    #src = Magick::Image.read("composite1-src.gif")[0]
    image_dir = Utils::createDirIfNeeded('images')
    
    # result = dst.composite(src, Magick::CenterGravity, Magick::OverCompositeOp)
    # result = dst.composite(src, 0, 0, Magick::OverCompositeOp)
    # result.write('./images/composites/composite1.gif')


    print "\nbeginning composites processing"
    Magick::CompositeOperator.values.each_with_index do |composite_style, index|
        print '.'
        result = dst.composite(src, 0, 0, composite_style)
        result.write("./#{image_dir}/gradient-composites/composite#{index}.gif")
    end
    puts "\ndone!"
end

def image_compositing_sample(options={})
    defaults = {num_operations: 5, append_op_to_filename: false, shuffle_composite_operations: false}
    options = defaults.merge!(options)
    
    images = Dir.entries("images").keep_if{|i| i =~ /\.jpg$/i}
    # dst_name = "circle works-it could go on forever.jpg"
    # src_name = "day rise over the fort.jpg"

    image_dir = Utils::createDirIfNeeded('images/image-composites')
    dst_name = images.shuffle!.sample
    images.delete(dst_name)
    raise if images.length == 0
    src_name = images.sample
    dst = Magick::Image.read("./images/#{dst_name}").first
    src = Magick::Image.read("./images/#{src_name}").first

    puts "beginning composites processing, using #{options[:num_operations]} different operations"
    
    newCompositeArray = Magick::CompositeOperator.values.shuffle if options[:shuffle_composite_operations]
    
    # first two CompositeOperator are basically no-ops, so skip 'em
    start_val = options[:shuffle_composite_operations] ? 0 : 2
    
    newCompositeArray[start_val..(options[:num_operations]+2)].each_with_index do |composite_style, index|
        print '.'
        append_string = options[:append_op_to_filename] ? composite_style.to_s : index
        result = dst.composite(src, 0, 0, composite_style)
        extension_regex = /\.jpg$/i
        result.write("./#{image_dir}/#{dst_name.gsub(extension_regex, '')}--#{src_name.gsub(extension_regex, '')}--#{append_string}.jpg")
    end
    puts "\ndone!"
    $BatchesRun += 1

end

# gradient_compositing_sample
2.times {image_compositing_sample(num_operations: 6, append_op_to_filename: true, shuffle_composite_operations: true)}

puts "BatchesRun: #{$BatchesRun}"