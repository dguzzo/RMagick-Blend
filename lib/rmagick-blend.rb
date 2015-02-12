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
  OPTIMIZED_NUM_OPERATION_SMALL = 14
  
	class Blend
		@options = {}
    @optimized_num_operation_large = 24

		attr_reader :options

		def start
			load_settings_from_file

      $specific_comps_to_run = nil

      @comp_sets = {
        copy_color: Set.new(%w(CopyBlueCompositeOp CopyCyanCompositeOp CopyGreenCompositeOp CopyMagentaCompositeOp CopyRedCompositeOp CopyYellowCompositeOp)),
        reliable_quality: Set.new(%w(BlendCompositeOp HardLightCompositeOp LinearLightCompositeOp OverlayCompositeOp DivideCompositeOp DarkenCompositeOp)),
        crazy: Set.new(%w(DistortCompositeOp DivideCompositeOp AddCompositeOp SubtractCompositeOp DisplaceCompositeOp)),
        specific: Set.new(%w(OverlayCompositeOp)),
        avoid: Set.new(%w(NoCompositeOp UndefinedCompositeOp XorCompositeOp SrcCompositeOp SrcOutCompositeOp DstOutCompositeOp OutCompositeOp ClearCompositeOp SrcInCompositeOp DstCompositeOp AtopCompositeOp SrcAtopCompositeOp InCompositeOp BlurCompositeOp DstAtopCompositeOp OverCompositeOp SrcOverCompositeOp ChangeMaskCompositeOp CopyOpacityCompositeOp CopyCompositeOp ReplaceCompositeOp DstOverCompositeOp DstInCompositeOp CopyBlackCompositeOp DissolveCompositeOp))
      }

      @comp_sets[:avoid].clear.merge(Settings.behavior[:specific_avoid_ops].split) if Settings.behavior[:specific_avoid_ops]
      # TODO
      # $specific_comps_to_run = $COMP_SETS[:specific]

      ###
			configure_options
      create_blends
    end
    
    :private
    def create_blends
      if RMagickBlend::BatchRunner::large_previous_batch?(@options)
        @options.merge!({
          num_operations: @optimized_num_operation_large,
          use_history: true
        })
        puts "running large batch using history file"
      end

      RMagickBlend::BatchRunner::delete_last_batch if Settings.behavior[:delete_last_batch]

      start_time = Time.now
      Settings.behavior[:batches_to_run].times do |index|
        puts "running batch #{index + 1} of #{Settings.behavior[:batches_to_run]}..."
        RMagickBlend::Compositing::composite_images(@options, @comp_sets)
      end
      end_time = Time.now
      puts "ran #{Settings.behavior[:batches_to_run]} batch(es) in #{Utils::ColorPrint::green(end_time-start_time)} seconds."

      RMagickBlend::BatchRunner::open_files
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
        append_operation_to_filename: true, 
        shuffle_composite_operations: true,
        input_file_format: Settings.default_input_image_format,
        output_file_format: Settings.default_output_image_format
      }

			normalize_options
		end


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
      Settings.behavior[:open_files_at_end_force] ||= false
      Settings.behavior[:open_files_at_end_suppress] ||= false
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
