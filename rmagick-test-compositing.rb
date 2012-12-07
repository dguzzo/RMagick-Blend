require 'RMagick'

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
  result.write("./images/composites/composite#{index}.gif")
end
puts "\ndone!"
