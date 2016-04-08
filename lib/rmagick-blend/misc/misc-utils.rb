module RMagickBlend
  module MiscUtils
    def self.load_sample_images
      images = []
      images << Magick::Image.read('assets/images/batch-8-source/9252445443_5c5c679774_c.jpg').first \
        << Magick::Image.read('assets/images/batch-8-source/9255227572_d49d429426_c.jpg').first
    end
  end
end
    
    
