module Utils
  def self.createDirIfNeeded(image_dir_name)
    unless File.directory?(image_dir_name)
      puts "creating directory '#{image_dir_name}'..."
      Dir.mkdir(image_dir_name)
    end
    image_dir_name
  end
  
  module ColorPrint
    def self.green(message)
      "\e[1;32m#{message} \e[0m"
    end

    def self.yellow(message)
      "\e[1;33m#{message} \e[0m"
    end

    def self.red(message)
      "\e[1;31m#{message} \e[0m"
    end
  end
  
end

