require 'rmagick-blend'

namespace :batch do
    desc "make blends"
    task :run do
        RMagickBlend::start
    end
end

namespace :get_material do
    desc "get faves"
    task :get_flickr_faves do
        require 'ruby-flickr'
        ruby_flickr = RubyFlickr.new
        ruby_flickr.get_creative_common_faves
    end
end
