require 'syslog'
require 'dguzzo-utils'

module RMagickBlend
  module FileUtils
    EXTENSION_REGEX = /\.[[:alpha:]]+$/i
    FILENAME_REGEX = /\/([^\/]*)$/i

    def self.output_all_composite_ops
      File.open('all_ops.yml', 'w') do |file|
        all_ops = Magick::CompositeOperator.values.map do |op| 
          op.to_s.force_encoding("UTF-8") # this is necessary for the file to write propoerly
        end
        file.write(all_ops.to_yaml)
      end
    end

    def self.output_all_composite_ops_txt
      File.open('all_ops.txt', 'w') do |file|
        all_ops = Magick::CompositeOperator.values.map do |op| 
          op.to_s.force_encoding("UTF-8") # this is necessary for the file to write propoerly
        end
        file.write(all_ops.join("\n"))
      end
    end

    def self.pretty_file_name(image_file)
      begin
        image_file.filename.gsub(EXTENSION_REGEX, '').match(FILENAME_REGEX)[1]
      rescue
        fallback_string = "improper-filename-#{Time.now.asctime}"
        Syslog.open { Syslog.notice("#{__FILE__} - #{fallback_string}") }
        fallback_string
      end
    end

    def self.get_imagemagick_pair(directories, file_format)
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

   def self.swap_directories(src, dest)
      puts "#{DguzzoUtils::ColorPrint::yellow('swapping')} source and destination files..."
      src, dest = dest, src
      [src, dest]
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

    def self.get_all_images_from_dir(dir, file_format)
      image_names = Dir.entries("#{dir}").keep_if{ |i| i =~ /\.#{file_format}$/i }
      image_names.map{|name| "#{dir}/#{name}"}
    end

    def self.save_image(image, path)
      puts "writing file: #{path}"
      image.write(path)
    end

  end
end
