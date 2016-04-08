require 'FileUtils' unless defined?(FileUtils)
require 'dguzzo-utils'

module Utils
  def self.create_dir_if_needed(image_dir_name)
    unless File.directory?(image_dir_name)
      puts "creating directory '#{image_dir_name}'..."
      FileUtils.mkdir_p(image_dir_name)
    end
    image_dir_name
  end

  def self.exit_with_message(message)
    puts DguzzoUtils::ColorPrint.red(message)
    exit
  end
end
