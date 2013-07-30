require 'pry'
require 'pry-nav'

module RMagickBlend

    module Special
        
        def self.distort
            image = load_image
            
            # UndefinedDistortion AffineDistortion AffineProjectionDistortion ArcDistortion PolarDistortion DePolarDistortion BarrelDistortion BilinearDistortion BilinearForwardDistortion BilinearReverseDistortion PerspectiveDistortion PerspectiveProjectionDistortion PolynomialDistortion ScaleRotateTranslateDistortion ShepardsDistortion BarrelInverseDistortion
            
            distort_operation = Magick::BilinearReverseDistortion
            points = [0, 0, 26, 0, 128, 0, 114, 23, 128, 128, 128, 100, 0, 128, 0, 123]
            # points = [0.0, 0.0, -0.5, 1.5, 0.0, 0.0, 0.3, 0.5]
            
            3.times do |i|
                image = image.distort(distort_operation, points) do
                    # self.define "distort:viewport", "44x44+115+0"
                    self.define "distort:scale", i+2
                end
                path = "assets/images/distort_test/sample_distort_#{i}.jpg"
                puts "writing file: #{path}"
                image.write(path)
            end
        end
        
        def self.distort_arc(variants, options = {})
            options = {arc_angle: 60, rotate_angle: 0, top_radius: 100, bottom_radius: 100}.merge(options)
            image = load_image
            
            variants.times do |i|
                arc_angle = options[:arc_angle] || 60
                #args: arc_angle   rotate_angle   top_radius   bottom_radius
                mod_image = image.dup.distort(Magick::ArcDistortion, [arc_angle + 20*i, options[:rotate_angle], options[:top_radius], options[:bottom_radius] ])
                save_image(mod_image, "assets/images/distort_test/sample_distort_#{i}")
            end
        end

        def self.animated_gif_of_dir_images(dir)
            image_names = RMagickBlend::FileUtils::get_all_images_from_dir(dir, 'jpg')
            anim = Magick::ImageList.new(*image_names)
            anim.write("#{dir}/animated.gif")
        end
   
        def self.swirl(deg)
            image = load_image
            mod_image = image.swirl(clamp_degrees(deg))
            save_image(mod_image, "assets/images/swirl_test.jpg")
        end
        
        private

        def self.clamp_degrees(deg)
            max = 360*24
            min = max * -1
            return max if deg > max #heuristic
            return min if deg < min
            deg
        end
        
        def self.load_image
            Magick::Image.read('assets/images/batch-8-source/9252445443_5c5c679774_c.jpg').first
        end
        
        def self.save_image(image, path)
            puts "writing file: #{path}"
            image.write(path)
        end
        
    end
    
end