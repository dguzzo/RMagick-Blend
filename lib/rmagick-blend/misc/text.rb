require 'pry'
require 'pry-nav'

module RMagickBlend
  module Text
    def self.bottom_center_title(text)
      image = RMagickBlend::MiscUtils::load_sample_images[1]

      title = Magick::Draw.new

      title.annotate(image, 0,0,0,20, text) do
        # self.font_family = 'Papyrus'
        self.fill = 'white'
        self.stroke = 'black'
        self.stroke_width = 2
        self.kerning = 7
        self.pointsize = 42
        self.font_weight = Magick::BoldWeight
        self.gravity = Magick::SouthGravity
        # self.undercolor = "rgba(0,0,0,0.4)"
      end

      RMagickBlend::FileUtils::save_image(image, "assets/images/text_test.jpg")
    end


    def self.meme_title(top_text, bottom_text, pointsize=50)
      image = RMagickBlend::MiscUtils::load_sample_images[1]

      draw_text = Magick::Draw.new
      draw_text.fill = 'white'
      draw_text.stroke = 'black'
      draw_text.stroke_width = 2
      draw_text.pointsize = pointsize
      draw_text.font_weight = Magick::BoldWeight
      draw_text.gravity = Magick::NorthGravity

      draw_text.annotate(image, 0,0,0,20, top_text)
      draw_text.gravity = Magick::SouthGravity
      draw_text.annotate(image, 0,0,0,20, bottom_text)

      RMagickBlend::FileUtils::save_image(image, "assets/images/text_meme_test.jpg")
    end
  end
end
