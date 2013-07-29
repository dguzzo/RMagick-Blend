module RMagickBlend

    module Special
        
        def self.distort
            image = load_image
            
            #[UndefinedDistortion=0, AffineDistortion=1, AffineProjectionDistortion=2, ArcDistortion=9, PolarDistortion=10, DePolarDistortion=11, BarrelDistortion=14, BilinearDistortion=6, BilinearForwardDistortion=6, BilinearReverseDistortion=7, PerspectiveDistortion=4, PerspectiveProjectionDistortion=5, PolynomialDistortion=8, ScaleRotateTranslateDistortion=3, ShepardsDistortion=16, BarrelInverseDistortion=15]
            
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
        
        def self.distort_arc(variants)
            image = load_image
            
            variants.times do |i|
                #args: arc_angle   rotate_angle   top_radius   bottom_radius
                
                image = image.distort(Magick::ArcDistortion, 60) do
                    # self.define "distort:scale", i+2
                end

                save_image(image)
            end
            
        end
        
        private
        
        def load_image
            Magick::Image.read('assets/images/batch-8-source/9252445443_5c5c679774_c.jpg').first
        end
        
        def save_image
            path = "assets/images/distort_test/sample_distort_#{i}.jpg"
            puts "writing file: #{path}"
            image.write(path)
        end
        
    end
    
end