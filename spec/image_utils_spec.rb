require 'RMagick'
require 'spec_helper'
require 'rmagick-blend/image_utils'

describe "ImageUtils" do
  describe "match_image_sizes" do

    src, dest = nil

    it "resizes dest image if source image is smaller" do
      src, dest = Magick::Image.new(100, 100), Magick::Image.new(200, 200) 
      src, dest = RMagickBlend::ImageUtils::match_image_sizes(src, dest)
      expect(dest.bounding_box.width).to eq(src.bounding_box.width)
    end
    
    it "resizes src image if dest image is smaller" do
      src, dest = Magick::Image.new(100, 100), Magick::Image.new(50, 200) 
      src, dest = RMagickBlend::ImageUtils::match_image_sizes(src, dest)
      expect(src.bounding_box.width).to eq(dest.bounding_box.width)
    end

    it "does not resize if both images are the same size" do
      src, dest = Magick::Image.new(200,200), Magick::Image.new(200, 200) 
      src, dest = RMagickBlend::ImageUtils::match_image_sizes(src, dest)
      expect(dest.bounding_box.width).to eq(src.bounding_box.width)
    end

  end
end

