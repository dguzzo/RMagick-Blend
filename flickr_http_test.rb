# http test

require 'net/http'
require 'xmlsimple'
require 'pp'
require 'json'
require './lib/colorprint'

class Flickr_API

  attr_reader :faves, :favesXML, :titles

  def initialize
    @titles = []
    @faves = {}
    @favesXML = nil
  end

  def get_flickr_faves
    puts 'accessing api.flickr.com ...'
    @favesXML = Net::HTTP.get('api.flickr.com', '/services/feeds/photos_faves.gne?id=49782305@N02')
    @faves = XmlSimple.xml_in(@favesXML) # converts XML response to a Ruby hash
    @faves = @faves['entry']
    
    #pp faves
    @faves.each do |photo|
      puts "#{ColorPrint::green(photo['title'][0])} by #{photo['author'][0]['name'][0]}" rescue ''
      @titles << photo['title'].first rescue photo['title']
    end
    
    write_titles_to_file
    open_files_in_browser if should_open_files_at_end
  end

  def open_files_in_browser
    last_file_href = @faves['entry'].last['link'][0]['href']
    second_to_last_file_href = @faves['entry'][@faves['entry'].length-2]['link'][0]['href']

    puts "opening: #{ColorPrint::yellow(last_file_href)}"
    %x(open "#{last_file_href}")
    puts "opening: #{ColorPrint::yellow(second_to_last_file_href)}"
    `open "#{second_to_last_file_href}"`
  end

  def save_favorite(index)
    image_dir = 'images'
    create_image_dir(image_dir) unless File.directory?(image_dir)
    
    photo = @faves[index]
    title = photo['title'][0]
    url = photo['link'][1]['href']
    uri = URI.parse(url)
    
    puts 'getting file...'
    response = Net::HTTP.get_response(uri)
    puts 'saving file...'
    File.open("#{image_dir}/#{title}.jpeg", 'w') do |file|
      file.write(response.body)
    end
  end

  private
  
  def create_image_dir(dir_name)
      puts "creating directory '#{dir_name}'..."
      Dir.mkdir(dir_name)
  end
  
  def should_open_files_at_end
    puts "\ndo you want files opened in the browser at the end? #{ColorPrint::red('y/n')}"
    @open_photos_at_end = gets.chomp
    @open_photos_at_end = !!@open_photos_at_end.match(/^(y|yes)/)
  end

  def write_titles_to_file
    myStr = @titles.join("\n")
    File.open("titles.txt", "w") do |file|
      file.write(myStr)
    end
  end

end
  
# f = Flickr_API.new
# f.get_flickr_faves
# sleep(2)
# f.open_files_in_browser