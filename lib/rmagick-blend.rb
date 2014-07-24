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
require 'pry'
require 'pry-nav'

module RMagickBlend
  OPTIMIZED_NUM_OPERATION_SMALL = 14
  
  def self.start
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
          $optimized_num_operation_large += 10
        end
        opts.on('-h', '--help', 'prints out this very help guide of options. yes, this one.') do |v| 
          puts "\n#{opts}"
          exit
        end
      end.parse!

      load_settings

      # TODO clean up all these globals/flags; it's madness now that the program is a gem
      $batches_ran = 0
      $optimized_num_operation_large = 24
      $num_operations ||= Settings.constant_values[:num_operations] || $flags[:num_operations] || OPTIMIZED_NUM_OPERATION_SMALL
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

      $COMP_SETS[:avoid].clear.push *Settings.behavior[:specific_avoid_ops].split if Settings.behavior[:specific_avoid_ops]
      # $specific_comps_to_run = $COMP_SETS[:specific]

      ###
      run_batch
    end

    def self.run_batch
      options = {
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

      if RMagickBlend::BatchRunner::large_previous_batch?(options)
        options.merge!({
            num_operations: $optimized_num_operation_large,
            use_history: true
        })
        puts "running large batch using history file"
      end

      RMagickBlend::BatchRunner::delete_last_batch if Settings.behavior[:delete_last_batch]

      start_time = Time.now
      Settings.behavior[:batches_to_run].times do |index|
          puts "running batch #{index + 1} of #{Settings.behavior[:batches_to_run]}..."
          RMagickBlend::Compositing::composite_images(options)
      end
      end_time = Time.now
      puts "ran #$batches_ran batch(es) in #{Utils::ColorPrint::green(end_time-start_time)} seconds."

      RMagickBlend::BatchRunner::open_files
    end
    private_class_method :run_batch
    
    def self.load_settings
      # check for gem's default config 
      default_settings = File.expand_path("../config/settings.yml", File.dirname(__FILE__))
      Utils::exit_with_message("default file at '#{default_settings}' does not exist!") unless File.exists?(default_settings)

      settings_path = File.expand_path("config/settings.yml")

      settings_path = if File.exists?(settings_path)
        settings_path
      else
        puts Utils::ColorPrint.yellow("Couldn't find custom settings file at #{settings_path}; using default rmagick-blend settings file")
        default_settings
      end

      Settings.load!(settings_path)
      Settings.behavior[:open_files_at_end_force] ||= false
      Settings.behavior[:open_files_at_end_suppress] ||= false
      puts "loaded \"#{Utils::ColorPrint::green(Settings.preset_name)}\" settings"
    end
    private_class_method :load_settings
end

__END__

Don't forget to read--and tell--stories.
