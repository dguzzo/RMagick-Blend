# This file was generated by the `rspec --init` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# Require this file using `require "spec_helper"` to ensure that it is only
# loaded once.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'
end

BASE_DIR = "#{Dir.getwd}/spec"
ASSETS_DIR = "#{BASE_DIR}/assets"

$:.unshift(File.expand_path('../vendor', File.dirname(__FILE__))) # allow easier inclusion of vendor files
require 'deep_symbolize'
require 'settings'
require 'yaml'

def create_temp_file(dir)
  image_name = Dir.entries(ASSETS_DIR).keep_if{|i| i =~ /\.jpg/}.first
  File.copy_stream("#{ASSETS_DIR}/#{image_name}", "#{ASSETS_DIR}/#{dir}/#{image_name}")
end

def clean_assets_directories
  clean_assets_directory('source')
  clean_assets_directory('destination')
end

def clean_assets_directory(dir)
  File.delete(*Dir["#{ASSETS_DIR}/#{dir}/*"])
end

def stub_input_for_gets(input)
  allow(RMagickBlend::BatchRunner).to receive_messages(:gets => input)
end

def create_history_file
  # todo: simplify
  File.open("#{BASE_DIR}/previous_batch.yml", 'w') do |file|
    file.write('')
  end
end

def delete_history_file
  file_path = "#{BASE_DIR}/previous_batch.yml"
  File.delete(file_path) if File.exists?(file_path)
end
