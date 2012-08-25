# http test

require 'net/http'
require 'xmlsimple'
require 'pp'
require 'json'
require_relative 'lib/colorprint'

class Flickr_API

  def initialize
    @titles = []
    @faves = {}
  end

  def get_flickr_faves
    
    should_open_files_at_end
    
    faves_xml = Net::HTTP.get('api.flickr.com', '/services/feeds/photos_faves.gne?id=49782305@N02')
    @faves = XmlSimple.xml_in(faves_xml)
    
    #pp faves
    @faves['entry'].each do |entry|
      puts "#{ColorPrint::green(entry['title'][0])} by #{entry['author'][0]['name'][0]}" rescue ''
      @titles << entry['title']
    end
    
    write_titles_to_file
    open_files_in_browser if @open_photos_at_end
    
  end

  private
  def should_open_files_at_end
    puts "\ndo you want files opened in the browser at the end? #{ColorPrint::red('y/n')}"
    @open_photos_at_end = gets.chomp
    @open_photos_at_end = !!@open_photos_at_end.match(/^(y|yes)/)
  end

  def write_titles_to_file
    myStr = @titles.join("\n")
    titles_file = File.new("titles.txt", "w")
    titles_file.write(myStr)
    # titles_file.write("\n\n")
    # titles_file.write(@faves['entry'].to_json)
    titles_file.close
  end

  def open_files_in_browser
    last_file_href = @faves['entry'].last['link'][0]['href']
    second_to_last_file_href = @faves['entry'][@faves['entry'].length-2]['link'][0]['href']

    puts "opening: #{ColorPrint::yellow(last_file_href)}"
    %x(open "#{last_file_href}")
    puts "opening: #{ColorPrint::yellow(second_to_last_file_href)}"
    `open "#{second_to_last_file_href}"`
  end
  
end
  
f = Flickr_API.new
f.get_flickr_faves