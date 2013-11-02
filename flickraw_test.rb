require 'flickraw'
require 'pry'
require 'pry-nav'
require './lib/utils'
require './vendor/deep_symbolize.rb'
require './vendor/settings.rb'
require 'yaml'

LICENSE_ID = 3

class FlickrawBasic
  attr_reader :token, :login

  def initialize
    load_settings
    set_basic_auth
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


  def get_creative_common_faves
    set_local_auth

    begin
      @login = flickr.test.login
      puts "You are now authenticated as #{@login.username} with token #{flickr.access_token} and secret #{flickr.access_secret}"
    rescue FlickRaw::FailedResponse => e
      puts "Authentication failed : #{e.msg}"
    end

=begin
  ## p flickr.photos.licenses.getInfo
  All Rights Reserved - 0
  Attribution License - 4
  Attribution-NoDerivs License - 6
  Attribution-NonCommercial-NoDerivs License - 3
  Attribution-NonCommercial License - 2
  Attribution-NonCommercial-ShareAlike License - 1
  Attribution-ShareAlike License - 5
  No known copyright restrictions - 7
  United States Government Work - 8
=end

    photos = flickr.photos.search(:user_id => 'me', :license => LICENSE_ID, :faves => 1)
    
    urls = photos.map do |p|
      ## slow
      info = flickr.photos.getInfo(:photo_id => p['id'])
      # FlickRaw.url_b(info)
      write_file_info(info)
      
      ## fast
      "http://farm#{p['farm']}.staticflickr.com/#{p['server']}/#{p['id']}_#{p['secret']}.jpg"
    end

    # download_files_from_urls(urls)
  end
  
  def download_files_from_urls(urls)
    new_dir = "images-license-#{LICENSE_ID}"
    Utils.createDirIfNeeded(new_dir)
    Dir.chdir(new_dir)
    
    urls.each do |url|
      `wget '#{url}'` 
    end    
  end

  private
  # http://makandracards.com/makandra/1309-sanitize-filename-with-user-input
  def sanitize_filename(filename)
    filename.gsub(/[^0-9A-z.\-]/, '_')
  end
  
  def write_file_info(photo)
    info_dir = 'photo-info'
    Utils.createDirIfNeeded(info_dir)
    title = sanitize_filename(photo.title)
    
    File.open("#{info_dir}/#{title}.yml", 'w') do |file|
      puts "writing file #{Utils::ColorPrint::green(title)}.yml..."
      file.write(custom_photo_info(photo).to_yaml)
    end
  end
  
  def custom_photo_info(photo)
    {
      "title" => photo.title,
      "owner" => {
        "username" => photo.owner.username,
        "realname" => photo.owner.realname,
        "nsid" => photo.owner.nsid,
        "profile_page" => "http://www.flickr.com/photos/#{photo.owner.username}/"
      },
      "urls" => {
        "photopage" => photo.urls.first._content
      }
    }
  end
  
  def set_local_auth
    flickr.access_token = Settings.authentication[:token][:access_token]
    flickr.access_secret = Settings.authentication[:token][:access_secret]
    flickr.access_token && flickr.access_secret
  end

  def set_basic_auth
    FlickRaw.api_key = Settings.authentication[:api_key]
    FlickRaw.shared_secret = Settings.authentication[:shared_secret]
    FlickRaw.api_key && FlickRaw.shared_secret
  end

  def ask_to_open(id)
    info = flickr.photos.getInfo(:photo_id => id)
    url = FlickRaw.url_b(info)
    %x(open "#{url}")
    user_url = FlickRaw.url_profile(info)
    %x(open "#{user_url}")
  end

  def load_settings
      Settings.load!("config/settings.yml")
      puts "loaded settings"
  end

end

test = FlickrawBasic.new
test.get_creative_common_faves
# # test.get_recent
# test.get_my_pubic_photos