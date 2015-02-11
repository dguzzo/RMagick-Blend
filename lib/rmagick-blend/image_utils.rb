module RMagickBlend
  module ImageUtils

    def self.match_image_sizes(src, dest)
      # based on width
      if src.bounding_box.x >= dest.bounding_box.x 
        src = src.resize(dest.bounding_box.x, dest.bounding_box.y)
      else
        dest = dest.resize(src.bounding_box.x, src.bounding_box.y)
      end
      [src, dest]
    end
    
  end
end
