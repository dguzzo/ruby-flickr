require 'flickraw'
require 'pry'
require 'pry-nav'
require 'ruby-flickr/utils'
require './vendor/deep_symbolize'
require './vendor/settings'
require 'yaml'

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

LICENSE_TEXT = {
    0 => "All Rights Reserved",
    4 => "Attribution License",
    6 => "Attribution-NoDerivs License",
    3 => "Attribution-NonCommercial-NoDerivs License",
    2 => "Attribution-NonCommercial License",
    1 => "Attribution-NonCommercial-ShareAlike License",
    5 => "Attribution-ShareAlike License",
    7 => "No known copyright restrictions",
    8 => "United States Government Work",
}.freeze

PER_PAGE = 10

class RubyFlickr
  attr_reader :token, :login

  def initialize(license = 5)
    load_settings
    set_basic_auth
    @token, @login = nil
    @license = license
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

  def get_creative_common_faves(page = 1)
    set_local_auth
    return unless @login

    print "getting up to #{Utils::ColorPrint::green(PER_PAGE)} creative common favorites with #{Utils::ColorPrint::green(LICENSE_TEXT[@license])} license..."

    photos = flickr.photos.search(:user_id => 'me', :license => @license, :faves => 1, per_page: PER_PAGE, page: page)
    photos_info = []

    if photos.to_a.empty?
      puts "\nzero photos found in search; exiting."
    else
        puts "\nfound #{photos.to_a.length} photos. fetching each...\n"
      urls = photos.map do |p|
        print "."
        photos_info << flickr.photos.getInfo(:photo_id => p['id'])
        photo_sizes = flickr.photos.getSizes(photo_id: p.id)

        begin
          photo_sizes.to_a.last.source
        rescue => e
          puts e
          "http://farm#{p['farm']}.staticflickr.com/#{p['server']}/#{p['id']}_#{p['secret']}.jpg"
        end
      end
      puts

      fetch_files(urls, photos_info)
    end
  end
  
  # currently just spits out titles of untagged photos
  def get_untagged
    set_local_auth
    untagged = flickr.photos.getUntagged

    if untagged
      Utils::ColorPrint::green_out("you have #{untagged.length} untagged photos." )
      untagged.each { |photo| puts photo.title } unless untagged.empty?
      untagged.length
    else
      Utils::ColorPrint::red_out("there was a problem with the flickr.photos.getUntagged call")
    end
  end
  
  #########
  private
  
  # http://makandracards.com/makandra/1309-sanitize-filename-with-user-input
  def sanitize_filename(filename)
      if !filename.is_a?(String)
          badname = "bad-file-name"
          Utils::ColorPrint::red_out("unreadable filename; can't sanitize. file being written with title: #{badname}" )
          return badname
      elsif filename.empty?
          return ""
      end
      filename.gsub(/[^0-9A-z.\-]/, '_')
  end
  
  def write_files_info(photos_info, urls)
    photos_info.each_with_index do |photo, index|
      info_dir = nil #'photo-info/'
      Utils.createDirIfNeeded(info_dir) if info_dir
      title = sanitize_filename(photo.title)
      file_path = "#{info_dir}#{title}.yml"
      
      if File.exists?(file_path)
        puts "skipping file-write #{file_path}; it already exists"
      else
        File.open(file_path, 'w') do |file|
          puts Dir.pwd
          puts "writing file #{Utils::ColorPrint::green(title)}.yml..."
          file.write(custom_photo_info(photo, urls[index]).to_yaml)
        end
      end
    end
  end
  
  def custom_photo_info(photo, url)
    {
      "titles" => {
        "original" => photo.title,
        "sanitized" => sanitize_filename(photo.title)
      },
      "owner" => {
        "username" => photo.owner.username,
        "realname" => photo.owner.realname,
        "nsid" => photo.owner.nsid,
        "profile_page" => "http://www.flickr.com/photos/#{photo.owner.username}/"
      },
      "urls" => {
        "photopage" => photo.urls.first._content,
        "largest_size" => url
      },
      "flickr_annotation" => {
        "flickr_title" => photo.title,
        "flickr_title_photo_page" => "#{photo.title} - #{photo.urls.first._content}",
        "username_profile_page" => photo.owner.username + " - http://www.flickr.com/photos/#{photo.owner.username}/",
      }
    }
  end
  
  def set_local_auth
    flickr.access_token = Settings.authentication[:token][:access_token]
    flickr.access_secret = Settings.authentication[:token][:access_secret]
    flickr.access_token && flickr.access_secret
    begin
      @login = flickr.test.login
      puts "You are now authenticated as #{@login.username} with token #{flickr.access_token} and secret #{flickr.access_secret}"
    rescue FlickRaw::FailedResponse => e
      puts "Authentication failed : #{e.msg}"
    end
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

  def fetch_files(urls, photos_info)
    new_dir = "assets/images-license-#{@license}"
    Utils.createDirIfNeeded(new_dir)

    Dir.chdir(new_dir) do
      urls.each_with_index do |url, index|
        download_name = sanitize_filename(photos_info[index].title) + ".jpg"
        `wget --no-clobber -O '#{download_name}' '#{url}'`
      end
      write_files_info(photos_info, urls) 
    end
  end
end
