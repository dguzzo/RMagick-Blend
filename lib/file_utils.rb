module RMagickBlend

    module FileUtils

        def self.createDirIfNeeded(image_dir_name)
            unless File.directory?(image_dir_name)
                puts "creating directory '#{image_dir_name}'..."
                Dir.mkdir(image_dir_name)
            end
            image_dir_name
        end

        def self.output_all_composite_ops
            File.open('all_ops.yml', 'w') do |file|
                all_ops = Magick::CompositeOperator.values.map{|op| op.to_s.force_encoding("UTF-8")}
                file.write(all_ops.to_yaml)
            end
        end

        def self.pretty_file_name(image_file)
            extension_regex = /\.[a-zA-Z]+$/i
            filename_regex = /\/([^\/]*)$/i
            begin
                image_file.filename.gsub(extension_regex, '').match(filename_regex)[1]
            rescue
                "improper-filename-#{Time.now.asctime}"
            end
        end

        def self.get_image_magick_pair(directories, file_format)
            destination_name, source_name = get_image_pair_via_directories(directories, file_format)
            source, destination = Magick::Image.read("./#{directories[:source]}/#{source_name}").first, Magick::Image.read("./#{directories[:destination]}/#{destination_name}").first

            [source, destination]
        end
    
        # provided a directory containing at least two images, pick two separate ones randomly as source image & destination image
        def self.get_image_pair_via_image_pool(file_format, dir = '.')
            image_names = Dir.entries("#{dir}").keep_if{ |i| i.downcase.end_with?(".#{file_format}") }
            raise "need at least two images to begin!" if image_names.length < 2

            destination_name = image_names.shuffle!.sample
            image_names.delete(destination_name)
            source_name = image_names.sample
            source, destination = Magick::Image.read("#{dir}/#{source_name}").first, Magick::Image.read("#{dir}/#{destination_name}").first

            [source, destination]
        end

        def self.get_image_pair_from_history(options)
            file_path = "#{options[:directories][:output]}/previous_batch.yml"
            Utils::exit_with_message("Can't find #{file_path}; exiting.") unless File.exists?(file_path) 

            history = File.read(file_path)
            history_hash = YAML.load(history)
            source, destination = history_hash[:src_name], history_hash[:dst_name]

            puts "loading source: #{Utils::ColorPrint::yellow( source )}\nloading destination: #{Utils::ColorPrint::yellow( destination )}"
            source, destination = Magick::Image.read(source).first, Magick::Image.read(destination).first

            [source, destination]
        end

        def self.swap_directories(src, dst)
            puts "#{Utils::ColorPrint::yellow('swapping')} source and destination files..."
            src, dst = dst, src
            [src, dst]
        end

        def self.get_image_pair_via_directories(directories, file_format)
            source_images = Dir.entries(directories[:source]).keep_if{ |i| i =~ /\.#{file_format}$/i }
            raise RuntimeError, "need at least one source image in #{directories[:source]} to begin!" if source_images.length < 1
            destination_images = Dir.entries(directories[:destination]).keep_if{ |i| i =~ /\.#{file_format}$/i }
            raise RuntimeError, "need at least one destination image in #{directories[:destination]} to begin!" if destination_images.length < 1

            destination_name, source_name = destination_images.shuffle!.sample, source_images.shuffle!.sample
            [destination_name, source_name]
            
            rescue Errno::ENOENT => e
                Utils::exit_with_message(e)
            rescue RuntimeError => e
                Utils::exit_with_message(e.message)
        end

        def self.save_history(args)
            src_name, dst_name = [ args[:src], args[:dst] ].map{ |file| file.filename.force_encoding("UTF-8") }
            save_path = "#{args[:options][:directories][:output]}/previous_batch.yml"
            puts "writing history file: #{save_path}"

            File.open(save_path, 'w') do |file|
                values = { src_name: src_name, dst_name: dst_name, options: args[:options] }
                file.write(values.to_yaml)
            end

            rescue => e
                puts Utils::ColorPrint::red("error in save_history #{e.message}")
        end

        def self.get_all_images_from_dir(dir, file_format)
            image_names = Dir.entries("#{dir}").keep_if{ |i| i =~ /\.#{file_format}$/i }
            image_names.map{|name| "#{dir}/#{name}"}
        end

        def self.load_sample_images
            images = []
            images << Magick::Image.read('assets/images/batch-8-source/9252445443_5c5c679774_c.jpg').first \
                << Magick::Image.read('assets/images/batch-8-source/9255227572_d49d429426_c.jpg').first
        end

        def self.save_image(image, path)
            puts "writing file: #{path}"
            image.write(path)
        end

    end
    
end