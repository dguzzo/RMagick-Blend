require 'RMagick'
require 'spec_helper'
require 'rmagick-blend/compositing'

describe "Compositing" do
  describe "match_image_sizes" do

    src, dest = nil

    it "resizes dest image if source image is smaller" do
      src, dest = Magick::Image.new(100, 100), Magick::Image.new(200, 200) 
      src, dest = RMagickBlend::Compositing::match_image_sizes(src, dest)
      expect(dest.bounding_box.x).to eq(src.bounding_box.x)
      expect(dest.bounding_box.y).to eq(src.bounding_box.y)
    end
    
    it "resizes src image if dest image is smaller" do
      src, dest = Magick::Image.new(100, 100), Magick::Image.new(50, 200) 
      src, dest = RMagickBlend::Compositing::match_image_sizes(src, dest)
      expect(src.bounding_box.x).to eq(dest.bounding_box.x)
      expect(src.bounding_box.y).to eq(dest.bounding_box.y)
    end

    it "does not resize if both images are the same size" do
      src, dest = Magick::Image.new(200,200), Magick::Image.new(200, 200) 
      src, dest = RMagickBlend::Compositing::match_image_sizes(src, dest)
      expect(dest.bounding_box.x).to eq(src.bounding_box.x)
      expect(dest.bounding_box.y).to eq(src.bounding_box.y)
    end

  end
end

