module RMagickBlend
  module ImageUtils

    # based solely on width
    def self.match_image_sizes(src, dest)
      return [src, dest] if src.bounding_box.x == dest.bounding_box.x
      
      if src.bounding_box.x > dest.bounding_box.x
        src = src.resize((dest.bounding_box.x).to_f/src.bounding_box.x)
      else
        dest = dest.resize((src.bounding_box.x).to_f/dest.bounding_box.x)
      end
      
      [src, dest]
    end
    
  end
end
