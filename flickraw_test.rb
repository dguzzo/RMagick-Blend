require 'flickraw'

class FlickrawBasic

  attr_reader :token, :login

  def initialize
    FlickRaw.api_key = "79f2e11b6b4e3213f8971bed7f17b4c4"
    FlickRaw.shared_secret = "ae82cca8fe3ec5e9"
    @token, @login = nil
  end

  def get_recent
    list   = flickr.photos.getRecent

    id     = list[0].id
    secret = list[0].secret
    info = flickr.photos.getInfo :photo_id => id, :secret => secret

    puts info.title           
    puts info.dates.taken     

    # sizes = flickr.photos.getSizes :photo_id => id
    # original = sizes.find {|s| s.label == 'Original' }
    # puts original.width       # => "800" -- may fail if they have no original marked image
    
    ask_to_open(id)
    
  end

  def get_my_pubic_photos
    @token = flickr.get_request_token
    auth_url = flickr.get_authorize_url(@token['oauth_token'], :perms => 'delete')

    puts "Open this url in your process to complete the authication process :\n#{Utils::ColorPrint::green(auth_url)}\n"
    puts "Copy here the number given when you complete the process."
    verify = gets.strip

    begin
      flickr.get_access_token(@token['oauth_token'], @token['oauth_token_secret'], verify)
      @login = flickr.test.login
      puts "You are now authenticated as #{@login.username} with token #{flickr.access_token} and secret #{flickr.access_secret}"
    rescue FlickRaw::FailedResponse => e
      puts "Authentication failed : #{e.msg}"
    end
    
    puts @login.inspect
    list = flickr.people.getPublicPhotos(:user_id => @login.id)
    
    id     = list[0].id
    secret = list[0].secret
    info = flickr.photos.getInfo :photo_id => id, :secret => secret
    
    puts info.title           # => "PICT986"
    puts info.dates.taken     # => "2006-07-06 15:16:18"
    
  end

  private
  def ask_to_open(id)
    info = flickr.photos.getInfo(:photo_id => id)
    url = FlickRaw.url_b(info)
    %x(open "#{url}")
    user_url = FlickRaw.url_profile(info)
    %x(open "#{user_url}")
  end

end

# test = FlickrawBasic.new
# # test.get_recent
# test.get_my_pubic_photos