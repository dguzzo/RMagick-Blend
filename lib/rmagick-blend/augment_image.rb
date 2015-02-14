# duck-punch Image class to make accessing image dimensions more convenient
module Magick
  class Image
    def width
      bounding_box.width
    end

    def height
      bounding_box.height
    end
  end
end

