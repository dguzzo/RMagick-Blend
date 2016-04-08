require 'RMagick'
require 'Set'
require 'dguzzo-utils'

require 'action_view'
require 'action_view/helpers'
include ActionView::Helpers::DateHelper

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
      @optimized_num_operation_large = 24
			
			load_settings_from_file
      @comp_sets = {}
      @comp_sets[:avoid] = Settings.op_presets[:avoid].split if Settings.op_presets[:avoid]
      
			normalize_options
    end

    def create_blends
      DguzzoUtils::ColorPrint::green_out("~~~~~ABOUT TO BLEND~~~~~")
      
      start_time = Time.now
      Settings.behavior[:batches_to_run].times do |index|
        puts "running batch #{index + 1} of #{Settings.behavior[:batches_to_run]}..."
        RMagickBlend::Compositing::composite_images(Settings._settings, @comp_sets)
      end
      
      duration = Time.now - (Time.now - start_time) # must be of Time type for time_ago_in_words()
      puts "ran #{Settings.behavior[:batches_to_run]} batch(es) in #{DguzzoUtils::ColorPrint::green(time_ago_in_words(duration))}."

    end

		def normalize_options
	    Utils::exit_with_message("both source and destinations directories are empty!") if Settings.directories[:source].empty? && Settings.directories[:destination].empty? 
			# if only one of source or destination directories is specified, it's implied that the same directory of images will be used for both pools
			Settings.directories[:source] = Settings.directories[:destination] if Settings.directories[:source].empty?
			Settings.directories[:destination] = Settings.directories[:source] if Settings.directories[:destination].empty?
		end

    :private
    def load_settings_from_file
      # check for the default config within this gem itself
      default_settings_path = File.expand_path("../config/settings.yml", File.dirname(__FILE__))
      Utils::exit_with_message("default file at '#{default_settings_path}' does not exist!\n run 'rake build:generate_config.'") unless File.exists?(default_settings_path)
      
      # check for user settings in arbitrary directory gem is used from, under hardcoded sub-dir
      user_settings_path = File.expand_path("config/settings.yml")
      
      settings_path = if File.exists?(user_settings_path)
        user_settings_path
      else
        puts DguzzoUtils::ColorPrint.yellow("Couldn't find custom settings file at #{user_settings_path}; using default rmagick-blend settings file.")
        default_settings_path
      end
      
      Settings.load!(settings_path)
      puts "loaded \"#{DguzzoUtils::ColorPrint::green(Settings.preset_name)}\" settings"
    end

	end

end

__END__

Don't forget to read--and tell--stories.
