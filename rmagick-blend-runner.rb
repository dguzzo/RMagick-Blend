### TODO: there is a major memory leak somewhere, possibly in the RMagick read() or write() functions. running even a few
### cycles of compositing on ~3-4MB files will quickly chew up 1.5GB of RAM, which isn't free'd until irb is quit.
###  this memory is of course freed when the program finishes when run directly with the 'ruby' command

require 'RMagick'
require './lib/utils.rb'
require './lib/file_utils.rb'
require './lib/compositing.rb'
require './lib/batch_runner.rb'
require './vendor/deep_symbolize.rb'
require './vendor/settings.rb'
require 'yaml'
require 'optparse'
require 'pry'
require 'pry-nav'

RMagickBlend::BatchRunner::load_settings

$batches_ran = 0
$optimized_num_operation_large = 24
$input_file_format = Settings.default_input_image_format
$output_file_format = Settings.default_output_image_format
$flags = {}
$specific_comps_to_run = nil
$COMP_SETS = {
    copy_color: %w(CopyBlueCompositeOp CopyCyanCompositeOp CopyGreenCompositeOp CopyMagentaCompositeOp CopyRedCompositeOp CopyYellowCompositeOp),
    reliable_quality: %w(BlendCompositeOp HardLightCompositeOp LinearLightCompositeOp OverlayCompositeOp DivideCompositeOp DarkenCompositeOp),
    crazy: %w(DistortCompositeOp DivideCompositeOp AddCompositeOp SubtractCompositeOp DisplaceCompositeOp),
    specific: %w(OverlayCompositeOp),
    avoid: %w(NoCompositeOp UndefinedCompositeOp XorCompositeOp SrcCompositeOp SrcOutCompositeOp DstOutCompositeOp OutCompositeOp ClearCompositeOp SrcInCompositeOp DstCompositeOp AtopCompositeOp SrcAtopCompositeOp InCompositeOp BlurCompositeOp DstAtopCompositeOp OverCompositeOp SrcOverCompositeOp ChangeMaskCompositeOp CopyOpacityCompositeOp CopyCompositeOp ReplaceCompositeOp DstOverCompositeOp DstInCompositeOp CopyBlackCompositeOp DissolveCompositeOp)
}

$COMP_SETS[:avoid].clear.push *Settings.behavior[:specific_avoid_ops].split if Settings.behavior[:specific_avoid_ops]
$COMP_SETS[:avoid].push *$COMP_SETS[:copy_color] if Settings.directories[:source] == "images/batch-7-source" ### TEMP for blind drawing proj only
# $specific_comps_to_run = $COMP_SETS[:specific]

OptionParser.new do |opts|
  opts.banner = "Usage: rmagick-blend.rb [options]"

  opts.on('-o', '--operations NUM', "number of blend operations to run [default is #{RMagickBlend::Compositing::OPTIMIZED_NUM_OPERATION_SMALL}]") { |v| $flags[:num_operations] = v }
  opts.on('-p', '--profile', "show timing profile debug info") { |v| $flags[:perf_profile] = v }
  opts.on('-s', '--swap', "swap the destination image and the source image") { |v| $flags[:switch_src_dest] = v }
  opts.on('-j', '--jpeg', "use jpg instead of bmp for composite output file") do 
      $output_file_format = "jpg"
      $optimized_num_operation_large += 10
  end
  opts.on('-h', '--help', 'Prints out this very help guide of options. yes, this one.') do |v| 
      $flags[:help] = v 
      puts "\n#{opts}"
      exit
  end
  # opts.on('-p', '--sourceport PORT', 'Source port') { |v| $flags[:source_port] = v }

end.parse!

# puts "YOUVE ACHIEVED HELP!\n #$flags" if $flags[:help]


###
def run_batch
    options = {
        directories: { source: Settings.directories[:source], destination: Settings.directories[:destination], output: Settings.directories[:output] },
        append_operation_to_filename: true, 
        shuffle_composite_operations: true,
        input_file_format: $input_file_format,
        output_file_format: $output_file_format
    }

    if RMagickBlend::BatchRunner::large_previous_batch?
        options.merge!({
            num_operations: $optimized_num_operation_large,
            use_history: true
        })
        puts "running large batch using history file"
    end

    RMagickBlend::BatchRunner::delete_last_batch if Settings.behavior[:delete_last_batch]

    start_time = Time.now
    Settings.behavior[:batches_to_run].times do 
        RMagickBlend::Compositing::composite_images(options)
    end
    end_time = Time.now
    puts "ran #$batches_ran batch(es) in #{Utils::ColorPrint::green(end_time-start_time)} seconds."
    
    RMagickBlend::BatchRunner::open_files
end

run_batch