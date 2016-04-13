require 'rmagick-blend/utils'
require 'dguzzo-utils'

module RMagickBlend
  module Compositing
    ORIG_FILES_OUTPUT_QUALITY = 30
    
    def self.composite_images(options={}, comp_sets)
      preview_image_paths = []

      # TODO simplify
      src, dest = options[:directories][:source] == options[:directories][:destination] ? 
        RMagickBlend::FileUtils::get_image_pair_via_image_pool(options[:input_image_format], options[:directories][:source]) : 
        RMagickBlend::FileUtils::get_imagemagick_pair(options[:directories], options[:input_image_format])

      src, dest = RMagickBlend::FileUtils::swap_directories(src, dest) if options[:behavior][:switch_src_dest]

      compositeArray = options[:behavior][:shuffle_composite_operations] ? Magick::CompositeOperator.values.dup.shuffle : Magick::CompositeOperator.values.dup
      compositeArray.delete_if { |op| comp_sets[:avoid].include?(op.to_s) }

      range = if options[:behavior][:shuffle_composite_operations]
				0...[options[:constant_values][:num_operations], Magick::CompositeOperator.values.length].min
      else
        # first two CompositeOperator are basically no-ops, so skip 'em. also, don't go out of bounds with the index
        2...[options[:constant_values][:num_operations] + 2, Magick::CompositeOperator.values.length].min
      end

      puts "\nbeginning composites processing, using #{DguzzoUtils::ColorPrint::green(options[:constant_values][:num_operations])} different operations"

      output_dir = create_output_dir(options, src, dest)

      # scale images to match
      src, dest = RMagickBlend::ImageUtils::match_image_sizes(src, dest) if options[:behavior][:match_image_sizes]

      # run composite operation (the meat of the program)
      compositeArray[range].each_with_index do |composite_style, index|
        print "#{(index.to_f/options[:constant_values][:num_operations]*100).round}% - "
        print "#{DguzzoUtils::ColorPrint::green(composite_style.to_s)}\n"
        append_string = options[:behavior][:append_operation_to_filename] ? composite_style.to_s : index
        result = dest.composite(src, 0, 0, composite_style)
        
        write_result(options, result, output_dir, append_string, src, dest)
        preview_image_paths << write_low_quality_preview(options, result, output_dir, append_string, src, dest) if options[:low_quality_preview]
      end

      save_orig_files_to_output(output_dir, src, dest) if options[:behavior][:save_orig_files_to_output]

      puts DguzzoUtils::ColorPrint::green("done!\n")
    end
    # end composite_images

    def self.create_output_dir(options, src, dest)
      # create & name output dir
      if options[:directories][:output_catalog_by_time]
        Utils::create_dir_if_needed(options[:directories][:output] + "/#{RMagickBlend::FileUtils::pretty_file_name(src)}--#{RMagickBlend::FileUtils::pretty_file_name(dest)}--#{Time.now.strftime("%m-%d-%y--%T")}")
      else
        Utils::create_dir_if_needed(options[:directories][:output])
      end
    end
    
    def self.write_result(options, result, output_dir, append_string, src, dest) 
      result.write("./#{output_dir}/#{RMagickBlend::FileUtils::pretty_file_name(src)}--#{RMagickBlend::FileUtils::pretty_file_name(dest)}--#{append_string}.#{options[:output_image_format]}") do
        self.quality = 100 if options[:output_image_format].downcase === 'jpg'
      end
    end

    def self.save_orig_files_to_output(output_dir, src, dest)
      src.write("./#{output_dir}/ORIG-SRC-#{RMagickBlend::FileUtils::pretty_file_name(src)}.jpg"){ self.quality = ORIG_FILES_OUTPUT_QUALITY }
      dest.write("./#{output_dir}/ORIG-DEST-#{RMagickBlend::FileUtils::pretty_file_name(dest)}.jpg"){ self.quality = ORIG_FILES_OUTPUT_QUALITY }
    end

    def self.write_low_quality_preview(options, result, output_dir, append_string, src, dest)
      result.resize!(0.6) if result.x_resolution.to_i > 3000 # heuristic
      filename = "PREVIEW-#{RMagickBlend::FileUtils::pretty_file_name(src)}--#{RMagickBlend::FileUtils::pretty_file_name(dest)}--#{append_string}.jpg"
      result.write("./#{output_dir}/#{filename}"){ self.quality = options[:constant_values][:preview_quality] }
      filename
    end

  end
end

