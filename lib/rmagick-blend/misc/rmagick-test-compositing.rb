require 'RMagick'
require './lib/utils'

def gradient_compositing_sample
    gold_fill = Magick::GradientFill.new(0, 0, 0, 0, "#f6e09a", "#cd9245")
    red_fill = Magick::GradientFill.new(0, 0, 0, 0, "#ff0000", "#ff8888")

    dst = Magick::Image.new(128, 128, gold_fill)
    src = Magick::Image.new(128, 128, red_fill)
    # src = Magick::Image.read("composite1-src.gif")[0]
    output_dir = Utils::create_dir_if_needed('images')
    
    print "\nbeginning composites processing"
    Magick::CompositeOperator.values.each_with_index do |composite_style, index|
        print '.'
        result = dst.composite(src, 0, 0, composite_style)
        result.write("./#{output_dir}/gradient-composites/composite#{index}.gif")
    end
    puts "\ndone!"
end

start_time = Time.now
gradient_compositing_sample
end_time = Time.now
puts "done in #{end_time-start_time} seconds."
