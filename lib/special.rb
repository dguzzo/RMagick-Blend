require 'pry'
require 'pry-nav'

module RMagickBlend

    module Special
        
        def self.distort
            
            image = RMagickBlend::FileUtils::load_sample_images.first
            
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
            image = RMagickBlend::FileUtils::load_sample_images.first
            
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
            image = RMagickBlend::FileUtils::load_sample_images.first
            mod_image = image.swirl(clamp_degrees(deg))
            save_image(mod_image, "assets/images/swirl_test.jpg")
        end
        
        def self.preview
            image = RMagickBlend::FileUtils::load_sample_images.first
            Magick::PreviewType.values.each do |op|
                mod_image = image.dup.preview(op)
                save_image(mod_image, "assets/images/preview_ops/preview_#{op}_test.jpg")
            end
        end
        
        def self.stereo
            images = RMagickBlend::FileUtils::load_sample_images
            image_left = images.first
            image_right = images[1]
            mod_image = image_left.stereo(image_right)
            save_image(mod_image, "assets/images/stereo_test.jpg")
        end
        
        def self.contrast(times)
            image = RMagickBlend::FileUtils::load_sample_images.first
            times.times do
                image = image.contrast(true)
            end
            save_image(image, "assets/images/contrast_test.jpg")
        end
        
        def self.fill_white_pixels
            puts 'searching white pixels...'
            pixel_with_coord = RMagickBlend::PixelLevelOps::find_first_pixel_of_color
            puts pixel_with_coord
            # puts "#{pixel} :: #{pixel.to_color}"
        end
        
        private

        def self.clamp_degrees(deg)
            max = 360*24
            min = max * -1
            return max if deg > max #heuristic
            return min if deg < min
            deg
        end
        
        def self.save_image(image, path)
            puts "writing file: #{path}"
            image.write(path)
        end
        
    end
    
end