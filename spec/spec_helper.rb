# This file was generated by the `rspec --init` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# Require this file using `require "spec_helper"` to ensure that it is only
# loaded once.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'
end

def create_temp_file(dir)
    base_dir = "#{Dir.getwd}/spec/assets"
    image_name = Dir.entries(base_dir).keep_if{|i| i =~ /\.jpg/}.first
    File.copy_stream("#{base_dir}/#{image_name}", "#{base_dir}/#{dir}/#{image_name}")
end

def clean_assets_directories
    clean_assets_directory('source')
    clean_assets_directory('destination')
end

def clean_assets_directory(dir)
    base_dir = "#{Dir.getwd}/spec/assets"
    File.delete(*Dir["#{base_dir}/#{dir}/*"])
end

def stub_input_for_gets(input)
    RMagickBlend::BatchRunner::stub(:gets).and_return(input)
end