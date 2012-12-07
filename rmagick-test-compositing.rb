require 'RMagick'

def gradient_compositing_sample
  gold_fill = Magick::GradientFill.new(0, 0, 0, 0, "#f6e09a", "#cd9245")
  red_fill = Magick::GradientFill.new(0, 0, 0, 0, "#ff0000", "#ff8888")

  dst = Magick::Image.new(128, 128, gold_fill)
  src = Magick::Image.new(128, 128, red_fill)
  #src = Magick::Image.read("composite1-src.gif")[0]

  # result = dst.composite(src, Magick::CenterGravity, Magick::OverCompositeOp)
  # result = dst.composite(src, 0, 0, Magick::OverCompositeOp)
  # result.write('./images/composites/composite1.gif')

  print "\nbeginning composites processing"
  Magick::CompositeOperator.values.each_with_index do |composite_style, index|
    print '.'
    result = dst.composite(src, 0, 0, composite_style)
    result.write("./images/gradient-composites/composite#{index}.gif")
  end
  puts "\ndone!"
end

def image_compositing_sample(num_operations = 5, append_op_to_filename = false)
  
  dst_name = "Hard Pill"
  src_name = "Turquoise Skies"
  
  dst = Magick::Image.read("./images/#{dst_name}.jpg").first
  src = Magick::Image.read("./images/#{src_name}.jpg").first
  
  puts "beginning composites processing, using #{num_operations}"
  # first two CompositeOperator are basically no-ops, so skip 'em
  Magick::CompositeOperator.values[2..(num_operations+2)].each_with_index do |composite_style, index|
    print '.'
    append_string = append_op_to_filename ? composite_style.to_s : index
    result = dst.composite(src, 0, 0, composite_style)
    result.write("./images/image-composites/#{dst_name}-#{src_name}-#{append_string}.jpg")
  end
  puts "\ndone!"
  
end

# gradient_compositing_sample
image_compositing_sample(10)
