require 'rmagick-blend/utils'

module RMagickBlend
  module BatchRunner
    YES_REGEX = /^(y|yes)/

    def self.open_files
      `open *.#$output_file_format` if open_files_at_end?( force: Settings.behavior[:open_files_at_end_force], suppress: Settings.behavior[:open_files_at_end_suppress] )
    end

    def self.open_files_at_end?(options = {})
      options = { force: false, suppress: false }.merge(options)
      return false if options[:suppress]

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
	end
end
