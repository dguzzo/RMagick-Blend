# http test

require 'net/http'
require 'xmlsimple'
require 'pp'
require 'json'
require './lib/utils'

class Flickr_API

  attr_reader :faves, :favesXML, :titles

  def initialize(get_faves = false)
    @titles = []
    @faves = {}
    @favesXML = nil
    get_flickr_faves if get_faves
  end

  def get_flickr_faves
    puts 'accessing api.flickr.com ...'
    @favesXML = Net::HTTP.get('api.flickr.com', '/services/feeds/photos_faves.gne?id=49782305@N02')
    @faves = XmlSimple.xml_in(@favesXML) # converts XML response to a Ruby hash
    @faves = @faves['entry'] # only care about the photos, not the meta data
    
    @faves.each do |photo|
      puts "#{Utils::ColorPrint::green(photo['title'][0])} by #{photo['author'][0]['name'][0]}" rescue ''
      @titles << photo['title'].first rescue photo['title']
    end
    
    write_titles_to_file
    should_open_files_at_end
  end

  def open_files_in_browser(num_to_open)
    0.upto(num_to_open - 1) do |photo_index|
      file_href = @faves[photo_index]['link'][0]['href']
      puts "opening: #{Utils::ColorPrint::yellow(file_href)}"
      %x(open "#{file_href}")
    end
  end

  # example usages:
  #f.save_favorite(3)
  #f.save_favorite(3, 7, 5)
  # f.save_favorite(*(16..20).to_a) ## l33t
  
  def save_favorite(*index)
    image_dir = Utils::createDirIfNeeded('images')
        
    index.each do |i|
        raise IndexError if i >= @faves.length
        photo = @faves[i]
        title = photo['title'][0]
        url = photo['link'][1]['href']
        uri = URI.parse(url)

        puts 'getting file...'
        response = Net::HTTP.get_response(uri)
        puts 'saving file...'
        File.open("#{image_dir}/#{title}.jpg", 'w') do |file|
            file.write(response.body)
        end

    end
    
    rescue IndexError => e
        puts "past the length of the array--stopping."
    
  end

  private
  
  def should_open_files_at_end
    puts "\ndo you want files opened in the browser at the end? #{Utils::ColorPrint::red('y/n')}"
    open_photos_at_end = !!(gets.chomp).match(/^(y|yes)/)
    
    if open_photos_at_end
      puts "\nhow many to open?"
      num_to_open = gets.chomp.to_i || 0 rescue 0
      open_files_in_browser num_to_open
    end
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