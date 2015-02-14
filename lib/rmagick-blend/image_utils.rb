module RMagickBlend
  module ImageUtils

    # based solely on width
    def self.match_image_sizes(src, dest)
      raise RuntimeError, "src image is nil" if src.nil? 
      raise RuntimeError, "dest image is nil" if dest.nil?
      
      return [src, dest] if src.width == dest.width
      
      if src.width > dest.width
        src = src.resize((dest.width).to_f/src.width)
      else
        dest = dest.resize((src.width).to_f/dest.width)
      end
      
      [src, dest]
    end
    
  end
end
