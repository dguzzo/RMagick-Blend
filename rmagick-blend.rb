### TODO: there is a major memory leak somewhere, possibly in the RMagick read() or write() functions. running even a few
### cycles of compositing on ~3-4MB files will quickly chew up 1.5GB of RAM, which isn't free'd until irb is quit.
###  this memory is of course freed when the program finishes when run directly with the 'ruby' command

require 'RMagick'
require './lib/utils.rb'
require './vendor/deep_symbolize.rb'
require './vendor/settings.rb'
require 'pp'
require 'yaml'
require 'optparse'
require 'pry'
require 'pry-nav'

Settings.load!("config/settings.yml")
$SETTINGS_NAME = Settings.preset_name
puts "loaded \"#{Utils::ColorPrint::green($SETTINGS_NAME)}\" settings"

$batches_run = 0
$optimized_num_operation_large = 20
OPTIMIZED_NUM_OPERATION_SMALL = 18
$file_format = Settings.default_image_format
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
$COMP_SETS[:avoid].push *$COMP_SETS[:copy_color] if Settings.directories[:source_dir] == "images/batch-7-source" ### TEMP for blind drawing proj only
# $specific_comps_to_run = $COMP_SETS[:specific]

OptionParser.new do |opts|
  opts.banner = "Usage: rmagick-blend.rb [options]"

  opts.on('-o', '--operations NUM', "number of blend operations to run [default is #{OPTIMIZED_NUM_OPERATION_SMALL}]") { |v| $flags[:num_operations] = v }
  opts.on('-p', '--profile', "show timing profile debug info") { |v| $flags[:perf_profile] = v }
  opts.on('-s', '--swap', "swap the destination image and the source image") { |v| $flags[:switch_src_dest] = v }
  opts.on('-j', '--jpeg', "use jpg instead of bmp for composite output file") do 
      $file_format = "jpg"
      $optimized_num_operation_large += 10
  end
  opts.on('-h', '--help', 'Prints out this very help guide of options. yes, this one.') do |v| 
      $flags[:help] = v 
      puts "\n#{opts}"
      exit
  end
  # opts.on('-p', '--sourceport PORT', 'Source port') { |v| $flags[:source_port] = v }

end.parse!

# puts "YOUVE ACHEIVED HELP!\n #$flags" if $flags[:help]

def image_compositing_sample(options={})
    defaults = {
        num_operations: OPTIMIZED_NUM_OPERATION_SMALL, 
        append_operation_to_filename: false, 
        shuffle_composite_operations: false,
        directories: { output_dir: 'images/image-composites' },
        file_format: 'jpg',
        save_history: true,
        use_history: false,
        switch_src_dest: false
    }
    
    options = defaults.merge(options)
    options[:num_operations] = $flags[:num_operations].to_i if $flags[:num_operations]
    options[:switch_src_dest] = $flags[:switch_src_dest] if $flags[:switch_src_dest]
    
    if options[:use_history]
        src, dst = RMagicBlend::FileUtils::get_image_pair_from_history(options)
    else
        src, dst = options[:directories] ? RMagicBlend::FileUtils::get_image_magick_pair(options[:directories], $file_format) : RMagicBlend::FileUtils::get_image_pair_via_image_pool($file_format, 'images')
    end

    src, dst = RMagicBlend::FileUtils::swap_directories(src, dst) if options[:switch_src_dest]
    
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
    output_dir = RMagicBlend::FileUtils::createDirIfNeeded(options[:directories][:output_dir])
    
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
        result.write("./#{output_dir}/#{RMagicBlend::FileUtils::pretty_file_name(dst)}--#{RMagicBlend::FileUtils::pretty_file_name(src)}--#{append_string}.#{options[:file_format]}")
        end_time = Time.now
        puts "PERF PROFILING .write(): #{Utils::ColorPrint::yellow(end_time-start_time)} seconds." if $flags[:perf_profile]
    end
    
    RMagicBlend::FileUtils::save_history(src: src, dst: dst, options: options) if options[:save_history]
    $batches_run += 1
    puts Utils::ColorPrint::green("\ndone!")
end


def delete_last_batch
    image_names = Dir.entries(Settings.directories[:output_dir]).keep_if{|i| i =~ /\.(jpg|bmp|tif)$/i}
    return if image_names.empty?
    image_names.map! {|name| "#{Settings.directories[:output_dir]}/#{name}" }
    puts "deleting all #{Utils::ColorPrint.red(image_names.length)} images of the last batch..."
    
    File.delete(*image_names)
end

###
def run_batch
    options = {
        directories: { source: Settings.directories[:source_dir], destination: Settings.directories[:destination_dir], output_dir: Settings.directories[:output_dir] },
        append_operation_to_filename: true, 
        shuffle_composite_operations: true,
        file_format: $file_format
    }

    if RMagicBlend::FileUtils::large_previous_batch?
        options.merge!({
            num_operations: $optimized_num_operation_large,
            use_history: true
        })
        puts "running large batch using history file"
    end

    delete_last_batch if Settings.behavior[:delete_last_batch]

    start_time = Time.now
    1.times do 
        image_compositing_sample(options)
    end

    end_time = Time.now
    puts "BatchesRun: #$batches_run in #{Utils::ColorPrint::green(end_time-start_time)} seconds."
    `open *.#$file_format` if RMagicBlend::FileUtils::open_files_at_end?(force: true, suppress: false)
end

run_batch
