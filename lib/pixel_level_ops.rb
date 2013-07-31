require 'pry'
require 'pry-nav'

module RMagickBlend

    class PixelWithCoord
        attr_reader :pixel, :x, :y
        
        def initialize(pixel, x, y)
            @pixel = pixel
            @x = x
            @y = y
        end
        
        def to_s
            "#{@pixel.to_color} at [#{@x},#{@y}]"
        end
        
    end
    
    module PixelLevelOps

        # TODO: not done
        def self.count_black_and_white_pixels(image=nil)
            image ||= RMagickBlend::FileUtils::load_sample_images.first
            counter, color = 0, nil
            image.each_pixel do |pixel, x, y|
                break if y > 20
                color = pixel.to_color
                puts "#{x},#{y} : #{color}" if color =~ /^(black|white)/
            end
        end

        def self.find_pixels_of_color(image, color_to_find=["black", '#000000'])
            puts 'searching pixels...'
            counter, color, found_pixels = 0, nil, []
            image.each_pixel do |pixel, x, y|
                color = pixel.to_color(Magick::AllCompliance, false, 8)

                if color_to_find.include?(color)
                    found_pixels << PixelWithCoord.new(pixel, x, y) 
                    puts "#{found_pixels.size} found"
                end
            end
            found_pixels
        end

    end
    
end