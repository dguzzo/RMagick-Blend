require 'RMagick'
require 'Set'

Dir[File.dirname(__FILE__) << "/rmagick-blend/*.rb"].each do |file|
  require file
end

$:.unshift(File.expand_path('../vendor', File.dirname(__FILE__))) # allow easier inclusion of vendor files
require 'deep_symbolize'
require 'settings'

require 'yaml'
require 'optparse'

module RMagickBlend
  OPTIMIZED_NUM_OPERATION_SMALL = 14
  
	class Blend
		@options = {}
    @optimized_num_operation_large = 24

		attr_reader :options

		def start
			$flags = {}
    	
			OptionParser.new do |opts|
      	opts.banner = "Usage: rmagick-blend.rb [options]"

        opts.on('-o', '--operations NUM', "number of blend operations to run [default is #{OPTIMIZED_NUM_OPERATION_SMALL}]") do |v| 
          $flags[:num_operations] = v
        end
        opts.on('-p', '--profile', "show timing profile debug info") do |v| 
          $flags[:perf_profile] = v
        end
        opts.on('-s', '--swap', "swap the destination image and the source image") do |v|
          $flags[:switch_src_dest] = v
        end
        opts.on('-j', '--jpeg', "use jpg instead of bmp for composite output file. overrides value in Settings.yml.") do 
          $output_file_format = "jpg"
          @optimized_num_operation_large += 10
        end
        opts.on('-h', '--help', 'prints out this very help guide of options. yes, this one.') do |v| 
          puts "\n#{opts}"
          exit
        end
      end.parse!

      load_settings_from_file

      # TODO clean up all these globals/flags; it's madness now that the program is a gem
      $input_file_format ||= Settings.default_input_image_format
      $output_file_format ||= Settings.default_output_image_format

      $specific_comps_to_run = nil
      $COMP_SETS = {
        copy_color: Set.new(%w(CopyBlueCompositeOp CopyCyanCompositeOp CopyGreenCompositeOp CopyMagentaCompositeOp CopyRedCompositeOp CopyYellowCompositeOp)),
        reliable_quality: Set.new(%w(BlendCompositeOp HardLightCompositeOp LinearLightCompositeOp OverlayCompositeOp DivideCompositeOp DarkenCompositeOp)),
        crazy: Set.new(%w(DistortCompositeOp DivideCompositeOp AddCompositeOp SubtractCompositeOp DisplaceCompositeOp)),
        specific: Set.new(%w(OverlayCompositeOp)),
        avoid: Set.new(%w(NoCompositeOp UndefinedCompositeOp XorCompositeOp SrcCompositeOp SrcOutCompositeOp DstOutCompositeOp OutCompositeOp ClearCompositeOp SrcInCompositeOp DstCompositeOp AtopCompositeOp SrcAtopCompositeOp InCompositeOp BlurCompositeOp DstAtopCompositeOp OverCompositeOp SrcOverCompositeOp ChangeMaskCompositeOp CopyOpacityCompositeOp CopyCompositeOp ReplaceCompositeOp DstOverCompositeOp DstInCompositeOp CopyBlackCompositeOp DissolveCompositeOp))
      }

      $COMP_SETS[:avoid].clear.merge(Settings.behavior[:specific_avoid_ops].split) if Settings.behavior[:specific_avoid_ops]
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
        RMagickBlend::Compositing::composite_images(@options)
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
        append_operation_to_filename: true, 
        shuffle_composite_operations: true,
        input_file_format: $input_file_format,
        output_file_format: $output_file_format
      }

			normalize_options
		end


    def load_settings_from_file
      # check for gem's default config 
      settings_path = File.expand_path("../config/settings.yml", File.dirname(__FILE__))
      Utils::exit_with_message("default file at '#{settings_path}' does not exist!\n run 'rake build:generate_config.'") unless File.exists?(settings_path)
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
