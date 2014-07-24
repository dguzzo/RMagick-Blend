# make sure the ImageMagick library itself is installed on the system, then:
# gem install rmagick

require 'RMagick'

image_name = "Bookshelves"
dest_path = Utils::create_dir_if_needed('images')
test_image = Magick::Image.read("./#{dest_path}/#{image_name}.jpg").first
cols, rows = test_image.columns, test_image.rows

puts "processing file #{image_name}..."
test_image[:caption] = "Hi!"
test_image = test_image.polaroid { self.gravity = Magick::CenterGravity }

test_image.change_geometry!("#{cols}x#{rows}") do |ncols, nrows, img|
  img.resize!(ncols, nrows)
end

puts "writing processed file..."
test_image.write("./#{dest_path}/#{image_name}_polaroid.png")
puts "done!"