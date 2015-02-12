module RMagickBlend
  module ImageUtils

    # based solely on width
    def self.match_image_sizes(src, dest)
      raise RuntimeError, "src image is nil" if src.nil? 
      raise RuntimeError, "dest image is nil" if dest.nil?
      
      return [src, dest] if src.bounding_box.width == dest.bounding_box.width
      
      if src.bounding_box.width > dest.bounding_box.width
        src = src.resize((dest.bounding_box.width).to_f/src.bounding_box.width)
      else
        dest = dest.resize((src.bounding_box.width).to_f/dest.bounding_box.width)
      end
      
      [src, dest]
    end
    
  end
end
