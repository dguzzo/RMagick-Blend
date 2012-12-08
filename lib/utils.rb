module Utils
  def self.createDirIfNeeded(image_dir_name)
    unless File.directory?(image_dir_name)
      puts "creating directory '#{image_dir_name}'..."
      Dir.mkdir(image_dir_name)
    end
    image_dir_name
  end
end