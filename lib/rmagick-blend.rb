require 'RMagick'
require 'Set'

Dir[File.dirname(__FILE__) << "/rmagick-blend/*.rb"].each do |file|
  require file
end

$:.unshift(File.expand_path('../vendor', File.dirname(__FILE__))) # allow easier inclusion of vendor files
require 'deep_symbolize'
require 'settings'

require 'yaml'

module RMagickBlend
	class Blend
		attr_reader :options

    def initialize
      @options = {}
      @optimized_num_operation_large = 24
			
			load_settings_from_file
      @comp_sets = {}
      @comp_sets[:avoid] = Settings.op_presets[:avoid].split if Settings.op_presets[:avoid]
      
			configure_options
    end

    def create_blends
      Utils::ColorPrint::green_out("~~~~~ABOUT TO BLEND~~~~~")
      
      start_time = Time.now
      Settings.behavior[:batches_to_run].times do |index|
        puts "running batch #{index + 1} of #{Settings.behavior[:batches_to_run]}..."
        RMagickBlend::Compositing::composite_images(@options, @comp_sets)
      end
      end_time = Time.now
      
      puts "ran #{Settings.behavior[:batches_to_run]} batch(es) in #{Utils::ColorPrint::green(end_time-start_time)} seconds."

    end

		def configure_options
      @options = {
        directories: { 
          source: Settings.directories[:source], 
          destination: Settings.directories[:destination], 
          output: Settings.directories[:output],
          output_catalog_by_time: Settings.directories[:output_catalog_by_time]
        },
				behavior: {
      		switch_src_dest: Settings.behavior[:switch_src_dest]
				},
        num_operations: Settings.constant_values[:num_operations],
        append_operation_to_filename: true, 
        shuffle_composite_operations: true,
        input_file_format: Settings.default_input_image_format,
        output_file_format: Settings.default_output_image_format
      }

			normalize_options
		end

    :private
    def load_settings_from_file
      # check for gem's default config 
      default_settings_path = File.expand_path("../config/settings.yml", File.dirname(__FILE__))
      Utils::exit_with_message("default file at '#{default_settings_path}' does not exist!\n run 'rake build:generate_config.'") unless File.exists?(default_settings_path)
      
      # check for user settings
      user_settings_path = File.expand_path("config/settings.yml")
      
      settings_path = if File.exists?(user_settings_path)
        user_settings_path
      else
        puts Utils::ColorPrint.yellow("Couldn't find custom settings file at #{user_settings_path}; using default rmagick-blend settings file")
        default_settings_path
      end
      
      Settings.load!(settings_path)
      puts "loaded \"#{Utils::ColorPrint::green(Settings.preset_name)}\" settings"
    end

		def normalize_options
	    Utils::exit_with_message("both source and destinations directories are empty!") if @options[:directories][:source].empty? && @options[:directories][:destination].empty? 
			# if only one of source or destination directories is specified, it's implied that the same directory of images will be used for both pools
			@options[:directories][:source] = @options[:directories][:destination] if @options[:directories][:source].empty?
			@options[:directories][:destination] = @options[:directories][:source] if @options[:directories][:destination].empty?
		end
    
	end

end

__END__

Don't forget to read--and tell--stories.
