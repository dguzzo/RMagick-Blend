require 'RMagick'
require 'spec_helper'
require 'rmagick-blend/image_utils'
require 'rmagick-blend/augment_image'

describe "ImageUtils" do
  describe "match_image_sizes" do

    src, dest = nil
    fill = Magick::HatchFill.new('red')

    it "resizes dest image if source image is smaller" do
      src, dest = Magick::Image.new(100, 100, fill), Magick::Image.new(200, 200, fill)
      src, dest = RMagickBlend::ImageUtils::match_image_sizes(src, dest)
      expect(dest.width).to eq(src.width)
    end
    
    it "resizes src image if dest image is smaller" do
      src, dest = Magick::Image.new(100, 100, fill), Magick::Image.new(50, 200, fill) 
      src, dest = RMagickBlend::ImageUtils::match_image_sizes(src, dest)
      expect(src.width).to eq(dest.width)
    end

    it "does not resize if both images are the same size" do
      src, dest = Magick::Image.new(200, 200, fill), Magick::Image.new(200, 200, fill) 
      src, dest = RMagickBlend::ImageUtils::match_image_sizes(src, dest)
      expect(dest.width).to eq(src.width)
    end

  end
end

