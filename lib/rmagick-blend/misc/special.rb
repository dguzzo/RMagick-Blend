require 'pry'
require 'pry-nav'

module RMagickBlend
    module Special
        def self.distort
            image = RMagickBlend::FileUtils::load_sample_images.first
            
=begin
UndefinedDistortion AffineDistortion AffineProjectionDistortion ArcDistortion PolarDistortion DePolarDistortion BarrelDistortion BilinearDistortion BilinearForwardDistortion BilinearReverseDistortion PerspectiveDistortion PerspectiveProjectionDistortion PolynomialDistortion ScaleRotateTranslateDistortion ShepardsDistortion BarrelInverseDistortion
=end
            
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
                RMagickBlend::FileUtils::save_image(mod_image, "assets/images/distort_test/sample_distort_#{i}")
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
            RMagickBlend::FileUtils::save_image(mod_image, "assets/images/swirl_test.jpg")
        end
        
        
        def self.preview
            image = RMagickBlend::FileUtils::load_sample_images.first
            Magick::PreviewType.values.each do |op|
                mod_image = image.dup.preview(op)
                RMagickBlend::FileUtils::save_image(mod_image, "assets/images/preview_ops/preview_#{op}_test.jpg")
            end
        end
        
        
        def self.stereo
            images = RMagickBlend::FileUtils::load_sample_images
            image_left = images.first
            image_right = images[1]
            mod_image = image_left.stereo(image_right)
            RMagickBlend::FileUtils::save_image(mod_image, "assets/images/stereo_test.jpg")
        end
        
        
        def self.contrast(times)
            image = RMagickBlend::FileUtils::load_sample_images.first
            times.times do
                image = image.contrast(true)
            end
            RMagickBlend::FileUtils::save_image(image, "assets/images/contrast_test.jpg")
        end
        
        
        def self.floodfill_pixels_of_color
            image = RMagickBlend::FileUtils::load_sample_images.first

            6.times do
                image = image.contrast(true)
            end
            
            pixels_of_color = RMagickBlend::PixelLevelOps::find_pixels_of_color(image)
            
            pixels_of_color.each do |pixel_with_coord|
                puts "#floodfilling based on #{pixel_with_coord}"
                image = image.color_floodfill(pixel_with_coord.x, pixel_with_coord.y, 'aquamarine')
            end
            
            RMagickBlend::FileUtils::save_image(image, "assets/images/floodfill_test.jpg")
        end
        
        
        def self.tile
            image = RMagickBlend::FileUtils::load_sample_images[1]
            tile_image = Magick::Image.read('assets/images/ruby_text_image.gif').first
            image.composite_tiled!(tile_image, Magick::DisplaceCompositeOp)
            image.write("assets/images/composite_tiled_test.jpg")
        end
        
        
        def self.montage(dir, random=false, samples=1)
            image_names = RMagickBlend::FileUtils::get_all_images_from_dir(dir, 'jpg')
            
            samples.times do |index|
                montage_name = "#{dir}/montage_#{index}.tif"
                random_label = random ? "random montage" : ""
                puts "creating #{random_label} #{Utils::ColorPrint::green(montage_name)}..."
                
                image_names = image_names.shuffle if random
                imageList = Magick::ImageList.new(*image_names)
                montage = imageList.montage do
                    self.background_color = 'black'
                    self.tile = "5x5"
                    self.geometry = "180x120+0+0"
                end
                montage.write(montage_name)
            end
        end
        
        
        private

        def self.clamp_degrees(deg)
            max = 360*24
            min = max * -1
            return max if deg > max #heuristic
            return min if deg < min
            deg
        end
        
    end
    
end