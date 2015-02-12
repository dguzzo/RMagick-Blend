require 'rmagick-blend/utils'

module RMagickBlend
  module Compositing
    def self.composite_images(options={})
      defaults = {
        num_operations: Settings.constant_values[:num_operations] || OPTIMIZED_NUM_OPERATION_SMALL, 
        append_operation_to_filename: false, 
        shuffle_composite_operations: false,
        directories: { output: 'images/image-composites' },
				behavior: {
        	switch_src_dest: false
		 		},
        input_file_format: 'jpg',
        output_file_format: 'jpg',
        save_history: true,
        use_history: false
      }

      options = defaults.merge(options)

      src, dest = if options[:use_history]
        RMagickBlend::FileUtils::get_image_pair_from_history(options)
      else
        options[:directories] ? RMagickBlend::FileUtils::get_imagemagick_pair(options[:directories], options[:input_file_format]) : RMagickBlend::FileUtils::get_image_pair_via_image_pool(options[:input_file_format], 'images')
      end

      src, dest = RMagickBlend::FileUtils::swap_directories(src, dest) if options[:behavior][:switch_src_dest]

      compositeArray = options[:shuffle_composite_operations] ? Magick::CompositeOperator.values.dup.shuffle : Magick::CompositeOperator.values.dup
      compositeArray.delete_if { |op| $COMP_SETS[:avoid].include?(op.to_s) }

      range = if $specific_comps_to_run
        options[:num_operations] = $specific_comps_to_run.length
        0...compositeArray.length
			elsif options[:shuffle_composite_operations]
				0...[options[:num_operations], Magick::CompositeOperator.values.length].min
      else
        # first two CompositeOperator are basically no-ops, so skip 'em. also, don't go out of bounds with the index
        2...[options[:num_operations] + 2, Magick::CompositeOperator.values.length].min
      end

      puts "\nbeginning composites processing, using #{Utils::ColorPrint::green(options[:num_operations])} different operations"

      output_dir = if options[:directories][:output_catalog_by_time]
        Utils::create_dir_if_needed(options[:directories][:output] + "/#{RMagickBlend::FileUtils::pretty_file_name(src)}--#{RMagickBlend::FileUtils::pretty_file_name(dest)}--#{Time.now.strftime("%m-%d-%y--%T")}")
      else
        Utils::create_dir_if_needed(options[:directories][:output])
      end

      src, dest = RMagickBlend::ImageUtils::match_image_sizes(src, dest) if Settings.behavior[:match_image_sizes]

      compositeArray[range].each_with_index do |composite_style, index|
        next if $specific_comps_to_run && !$specific_comps_to_run.include?(composite_style.to_s)

        print "#{(index.to_f/options[:num_operations]*100).round}% - " unless $specific_comps_to_run
        print "#{Utils::ColorPrint::green(composite_style.to_s)}\n"
        append_string = options[:append_operation_to_filename] ? composite_style.to_s : index
        result = dest.composite(src, 0, 0, composite_style)
        result.write("./#{output_dir}/#{RMagickBlend::FileUtils::pretty_file_name(src)}--#{RMagickBlend::FileUtils::pretty_file_name(dest)}--#{append_string}.#{options[:output_file_format]}") do
          self.quality = 100 if options[:output_file_format].downcase === 'jpg'
        end
        
        if Settings.low_quality_preview
          result.resize!(0.6) if result.x_resolution.to_i > 3000 # heuristic
          result.write("./#{output_dir}/PREVIEW-#{RMagickBlend::FileUtils::pretty_file_name(src)}--#{RMagickBlend::FileUtils::pretty_file_name(dest)}--#{append_string}.jpg"){ self.quality = 46 }
        end
      end

      RMagickBlend::FileUtils::save_history(src: src, dest: dest, options: options) if options[:save_history]
      puts Utils::ColorPrint::green("done!\n")
    end
    # end composite_images

  end
end

