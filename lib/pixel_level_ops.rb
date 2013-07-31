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

        def self.find_first_pixel_of_color(image=nil, color_to_find="black")
            image ||= RMagickBlend::FileUtils::load_sample_images.first
            counter, color = 0, nil
            image.each_pixel do |pixel, x, y|
                color = pixel.to_color
                return PixelWithCoord.new(pixel, x, y) if color == color_to_find
            end
            nil
        end

    end
    
end