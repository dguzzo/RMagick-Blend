require './lib/rmagick-blend/version'

Gem::Specification.new do |s|
  s.name = 'rmagick-blend'
  s.version = RMagickBlend::VERSION
  s.summary = 'A small program that uses RMagick-a gem that acts as a wrapper around the classic ImageMagick library-to run various composite operations on source images, producing a composite output.'
  s.authors = ['Dominick Guzzo']

  s.files = Dir['lib/**/*.rb', 'vendor/*.rb', 'config/default-settings.yml']

  s.add_runtime_dependency 'rmagick', '~> 2.15'
  s.add_runtime_dependency 'actionview', '~> 4.2'

  s.add_development_dependency 'rspec', '~> 3.4'
  s.add_development_dependency 'pry', '~> 0.9'
  s.add_development_dependency 'pry-nav', '0.2'
end
