require 'rmagick-blend/version'

Gem::Specification.new do |s|
    s.name = 'rmagick-blend'
    s.version = RMagickBlend::VERSION
    s.summary = 'A small program that uses RMagick-a gem that acts as a wrapper around the classic ImageMagick library-to run various composite operations on source images, producing a composite output.'
    s.authors = ['Dominick Guzzo']
    
    s.files = Dir['lib/**/*.rb', 'vendor/*.rb', 'config/settings.yml']
    
    s.add_dependency 'rmagick'
    s.add_dependency 'dguzzo-util'
    
    s.add_development_dependency 'rspec'
    s.add_development_dependency 'pry'
    s.add_development_dependency 'pry-nav'
end
