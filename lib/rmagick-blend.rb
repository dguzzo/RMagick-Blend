require 'pry'
require 'pry-nav'

module RMagickBlend

    OPTIMIZED_NUM_OPERATION_SMALL = 18
    
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
            image_names = Dir.entries("#{dir}").keep_if{ |i| i =~ /\.#{file_format}$/i }
            raise "need at least two images to begin!" if image_names.length < 2

            destination_name = image_names.shuffle!.sample
            image_names.delete(destination_name)
            source_name = image_names.sample
            source, destination = Magick::Image.read("#{dir}/#{source_name}").first, Magick::Image.read("#{dir}/#{destination_name}").first

            [source, destination]
        end

        def self.get_image_pair_from_history(options)
            begin
                file_path = "#{options[:directories][:output_dir]}/previous_batch.yml"
                raise "Can't find #{file_path}; exiting." unless File.exists?(file_path) # don't rescue, cuz not sure how i want the program to fail gracefully yet
            rescue => e
                puts Utils::ColorPrint.red(e.message)
                exit
            end

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
            source_images = Dir.entries(directories[:source]).keep_if{|i| i =~ /\.#{file_format}$/i}
            raise RuntimeError, "need at least one source image in #{directories[:source]} to begin!" if source_images.length < 1
            destination_images = Dir.entries(directories[:destination]).keep_if{|i| i =~ /\.#{file_format}$/i}
            raise RuntimeError, "need at least one destination image in #{directories[:destination]} to begin!" if destination_images.length < 1

            destination_name, source_name = destination_images.shuffle!.sample, source_images.shuffle!.sample
            [destination_name, source_name]
        end

        def self.save_history(args)
            src_name, dst_name = [ args[:src], args[:dst] ].map{ |file| file.filename.force_encoding("UTF-8") }
            save_path = "#{args[:options][:directories][:output_dir]}/previous_batch.yml"
            puts "writing history file: #{save_path}"

            File.open(save_path, 'w') do |file|
                values = { src_name: src_name, dst_name: dst_name, options: args[:options] }
                file.write(values.to_yaml)
            end

            rescue => e
                puts Utils::ColorPrint::red("error in save_history #{e.message}")
        end

    end

    module BatchRunner

        def self.open_files_at_end?(options = {})
            options = { force: false, suppress: false }.merge(options)
            return if options[:suppress]

            unless options[:force]
                puts "\ndo you want to open the files in Preview? #{Utils::ColorPrint::green('y/n')}"
                open_photos_at_end = !!(gets.chomp).match(/^(y|yes)/)
            end

            if options[:force] || open_photos_at_end
                Dir.chdir(Settings.directories[:output_dir])

                num_files_created = Dir.entries(Dir.pwd).keep_if{ |i| i =~ /\.#$output_file_format$/i }.length

                if num_files_created > Settings.constant_values[:num_files_before_warn]
                    puts "\n#{num_files_created} files were generated; opening them all could cause the system to hang. proceed? #{Utils::ColorPrint::yellow('y/n')}"
                    open_many_files = !!(gets.chomp).match(/^(y|yes)/)
                    return unless open_many_files
                end
                true
            end
        end

        def self.large_previous_batch?
            puts "\ndo you want to pursue the previous images in depth? #{Utils::ColorPrint::green('y/n')}"
            user_input = gets.strip
            !!(user_input =~ /^(y|yes)/) || user_input.empty?
        end

        def self.delete_last_batch
            image_names = Dir.entries(Settings.directories[:output_dir]).keep_if{|i| i =~ /\.(jpg|bmp|tif)$/i}
            return if image_names.empty?
            image_names.map! {|name| "#{Settings.directories[:output_dir]}/#{name}" }
            puts "deleting all #{Utils::ColorPrint.red(image_names.length)} images of the last batch..."

            File.delete(*image_names)
        end

    end

    module Compositing

        def self.composite_images(options={})
            defaults = {
                num_operations: OPTIMIZED_NUM_OPERATION_SMALL, 
                append_operation_to_filename: false, 
                shuffle_composite_operations: false,
                directories: { output_dir: 'images/image-composites' },
                input_file_format: 'jpg',
                output_file_format: 'jpg',
                save_history: true,
                use_history: false,
                switch_src_dest: false
            }

            options = defaults.merge(options)
            options[:num_operations] = $flags[:num_operations].to_i if $flags[:num_operations]
            options[:switch_src_dest] = $flags[:switch_src_dest] if $flags[:switch_src_dest]

            if options[:use_history]
                src, dst = RMagickBlend::FileUtils::get_image_pair_from_history(options)
            else
                src, dst = options[:directories] ? RMagickBlend::FileUtils::get_image_magick_pair(options[:directories], $input_file_format) : RMagickBlend::FileUtils::get_image_pair_via_image_pool($input_file_format, 'images')
            end

            src, dst = RMagickBlend::FileUtils::swap_directories(src, dst) if options[:switch_src_dest]

            compositeArray = options[:shuffle_composite_operations] ? Magick::CompositeOperator.values.dup.shuffle : Magick::CompositeOperator.values.dup
            compositeArray.delete_if { |op| $COMP_SETS[:avoid].include?(op.to_s) }

            if $specific_comps_to_run
                range = 0...compositeArray.length
                options[:num_operations] = $specific_comps_to_run.length
            else
                # first two CompositeOperator are basically no-ops, so skip 'em. also, don't go out of bounds with the index
                range = 2...[options[:num_operations] + 2, Magick::CompositeOperator.values.length].min
            end

            puts "\nbeginning composites processing, using #{Utils::ColorPrint::green(options[:num_operations])} different operations"
            output_dir = RMagickBlend::FileUtils::createDirIfNeeded(options[:directories][:output_dir])

            compositeArray[range].each_with_index do |composite_style, index|
                next if $specific_comps_to_run && !$specific_comps_to_run.include?(composite_style.to_s)

                puts "#{(index.to_f/options[:num_operations]*100).round}%" unless $specific_comps_to_run
                puts "#{Utils::ColorPrint::green(composite_style.to_s)}"
                append_string = options[:append_operation_to_filename] ? composite_style.to_s : index
                start_time = Time.now
                result = dst.composite(src, 0, 0, composite_style)
                end_time = Time.now
                puts "PERF PROFILING .composite(): #{Utils::ColorPrint::yellow(end_time-start_time)} seconds." if $flags[:perf_profile]

                start_time = Time.now
                result.write("./#{output_dir}/#{RMagickBlend::FileUtils::pretty_file_name(dst)}--#{RMagickBlend::FileUtils::pretty_file_name(src)}--#{append_string}.#{options[:output_file_format]}")
                end_time = Time.now
                puts "PERF PROFILING .write(): #{Utils::ColorPrint::yellow(end_time-start_time)} seconds." if $flags[:perf_profile]
            end

            RMagickBlend::FileUtils::save_history(src: src, dst: dst, options: options) if options[:save_history]
            $batches_run += 1
            puts Utils::ColorPrint::green("\ndone!")
        end
        
    end
    
end
