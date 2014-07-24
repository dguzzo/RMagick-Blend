require 'rmagick-blend/utils'

module RMagickBlend
  module BatchRunner
    YES_REGEX = /^(y|yes)/

    def self.open_files
      `open *.#$output_file_format` if open_files_at_end?( force: Settings.behavior[:open_files_at_end_force], suppress: Settings.behavior[:open_files_at_end_suppress] )
    end

    def self.open_files_at_end?(options = {})
      options = { force: false, suppress: false }.merge(options)
      return if options[:suppress]

      unless options[:force]
        puts "\ndo you want to open the files in Preview? #{Utils::ColorPrint::green('y/n')}"
        open_photos_at_end = !!(gets.chomp).match(YES_REGEX)
      end

      if options[:force] || open_photos_at_end
        Dir.chdir(Settings.directories[:output])

        num_files_created = Dir.entries(Dir.pwd).keep_if{ |i| i.downcase.end_with?(".#$output_file_format") }.length

        if num_files_created > Settings.constant_values[:num_files_before_warn]
          puts "\n#{num_files_created} files were generated; opening them all could cause the system to hang. proceed? #{Utils::ColorPrint::yellow('y/n')}"
          open_many_files = !!(gets.chomp).match(YES_REGEX)
          return unless open_many_files
        end
        true
      end
    end

    def self.large_previous_batch?(options = {})
      return false unless history_file_exists?(options)
      return false if Settings.behavior[:large_previous_batch_suppress]
      puts "\ndo you want to pursue the previous images in depth? (#{Utils::ColorPrint::green('y|yes')})"
      user_input = gets.strip
      !!(user_input =~ YES_REGEX) # || user_input.empty?
    end

    def self.delete_last_batch
      image_names = Dir.entries(Settings.directories[:output]).keep_if{|i| i =~ /\.(jpg|bmp|tif)$/i}
      return if image_names.empty?
      image_names.map! {|name| "#{Settings.directories[:output]}/#{name}" }
      puts "deleting all #{Utils::ColorPrint.red(image_names.length)} images of the last batch..."

      File.delete(*image_names)
      rescue Errno::ENOENT => e
        puts Utils::ColorPrint.yellow("can't delete files in #{Settings.directories[:output]}; make sure that that directory exists.")
    end
    
    def self.history_file_exists?(options = {})
      return false if options.empty?
      # DRY this out; it's called in verbatim another method 
      file_path = "#{options[:directories][:output]}/previous_batch.yml"
      File.exists?(file_path)
      rescue NoMethodError => e
        puts Utils::ColorPrint.yellow("Couldn't find history file: #{e}")
        return false
    end
    private_class_method :history_file_exists?
  end
end
