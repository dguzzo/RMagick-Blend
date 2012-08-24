# http test

require 'net/http'
require 'xmlsimple'
require 'pp'
require 'json'

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

def get_flickr_faves
  faves_xml = Net::HTTP.get('api.flickr.com', '/services/feeds/photos_faves.gne?id=49782305@N02')
  faves_ruby_hash = XmlSimple.xml_in(faves_xml)
end

# puts ARGV
puts "\ndo you want files opened in the browser at the end? #{ColorPrint::red('y/n')}"
openPhotos = gets.chomp
openPhotos = !!openPhotos.match(/^(y|yes)/)

#pp faves_ruby_hash
titles = []
faves_ruby_hash = get_flickr_faves
faves_ruby_hash['entry'].each do |entry|
  puts "#{ColorPrint::green(entry['title'][0])} by #{entry['author'][0]['name'][0]}" rescue ''
  titles << entry['title']
end

myStr = titles.join(', ')
titles_file = File.new("titles.txt", "w")
titles_file.write(myStr)
titles_file.write("\n\n")
titles_file.write(faves_ruby_hash['entry'].to_json)
titles_file.close

if openPhotos 
  last_file_href = faves_ruby_hash['entry'].last['link'][0]['href']
  second_to_last_file_href = faves_ruby_hash['entry'][faves_ruby_hash['entry'].length-2]['link'][0]['href']

  puts "opening: #{ColorPrint::yellow(last_file_href)}"
  %x(open "#{last_file_href}")
  puts "opening: #{ColorPrint::yellow(second_to_last_file_href)}"
  `open "#{second_to_last_file_href}"`
end
