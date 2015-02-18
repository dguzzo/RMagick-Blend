# add all files in /lib to path
$:.unshift File.join(File.dirname(__FILE__), "lib")
require 'rmagick-blend'

###

desc "show rake tasks"
task :default do
  puts `rake -T`
end

desc "run rspec tests"
task :test do
  puts `rspec`
end

namespace :build do
  desc "prepare for rspec"
  task :prepare_rspec do
    Utils::create_dir_if_needed(File.join('spec', 'assets', 'source'))
    Utils::create_dir_if_needed(File.join('spec', 'assets', 'destination'))
  end

	desc "generate default config file"
	task :generate_config do
		puts "generating default config file..."
		#TODO
	end
end

namespace :batch do
  desc "make blends"
  task :run do
    blender = RMagickBlend::Blend.new
    blender.create_blends
  end
end

namespace :get_material do
  desc "get faves"
  task :get_flickr_faves do
    begin
      require 'ruby-flickr'
      ruby_flickr = RubyFlickr.new
      ruby_flickr.get_creative_common_faves
    rescue LoadError
      Utils::exit_with_message("RubyFlickr not found -- visit https://github.com/dguzzo/ruby-flickr to get the gem")
    end
  end
end

desc "console"
task :console do
  require 'irb'
  require 'irb/completion'
  #require 'rmagick-blend' already required here at the top of this rakefile
  ARGV.clear
  IRB.start
end

