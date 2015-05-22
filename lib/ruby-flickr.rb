require 'flickraw'
$:.unshift(File.expand_path('../vendor', File.dirname(__FILE__))) # allow easier inclusion of vendor files
require 'deep_symbolize'
require 'settings'
require 'yaml'

require 'ruby-flickr/utils'

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

module RubyFlickr
  PER_PAGE = 10
  
  class API
    attr_reader :token, :login

    def initialize(license = 5)
      load_settings
      set_basic_auth
      @token, @login = nil
      @license = license
    end

    def get_recent_public_photos
      list = flickr.photos.getRecent(per_page: 10)

      list.each do |photo|
        info = flickr.photos.getInfo(photo_id: photo.id, secret: photo.secret)
        puts "#{photo.title} -- #{info.dates.taken}"
      end
    end
    
    def show_most_recent_public_photo 
      list   = flickr.photos.getRecent
      id     = list[0].id
      secret = list[0].secret
      info = flickr.photos.getInfo(photo_id: id, secret: secret)

      puts info.title           
      puts info.dates.taken     

      ask_to_open(id)
    end

    def get_my_public_photos(per_page = 20)
      user_id = Settings.user_id
      user = flickr.people.getInfo(user_id: user_id)

      Utils::ColorPrint::cyan_out("getting #{per_page} public photos for user #{user.username} (#{user_id})")

      public_photos = flickr.people.getPublicPhotos(user_id: user_id , extras: "url_o", per_page: per_page)
      
      if public_photos.to_a.empty?
        puts "\nzero photos found in search; exiting."
      else
        puts "\nfound #{public_photos.to_a.length} photos. fetching...\n"
        fetch_just_files(public_photos, "#{Utils::sanitize_filename(user.username)}-public-photos")
      end
    end

    def get_creative_common_faves(page = 1)
      set_local_auth
      return unless @login

      print "getting up to #{Utils::ColorPrint::green(PER_PAGE)} creative common favorites with #{Utils::ColorPrint::green(LICENSE_TEXT[@license])} license..."

      photos = flickr.photos.search(user_id: 'me', license: @license, faves: 1, per_page: PER_PAGE, page: page)
      photos_info = []

      if photos.to_a.empty?
        puts "\nzero photos found in search; exiting."
      else
        puts "\nfound #{photos.to_a.length} photos. fetching each...\n"
        urls = photos.map do |p|
          print "."
          photos_info << flickr.photos.getInfo(photo_id: p['id'])
          photo_sizes = flickr.photos.getSizes(photo_id: p.id)

          begin
            photo_sizes.to_a.last.source
          rescue => e
            puts e
            "http://farm#{p['farm']}.staticflickr.com/#{p['server']}/#{p['id']}_#{p['secret']}.jpg"
          end
        end

        fetch_files(urls, photos_info)
      end
    end

    # prints out titles of untagged photos
    def get_untagged(per_page = 100)
      set_local_auth
      untagged_photos = flickr.photos.getUntagged(per_page: per_page)

      if untagged_photos   
        Utils::ColorPrint::green_out("you have #{untagged_photos.length} untagged photos:" )
        Utils::ColorPrint::cyan_out("(note: these are not being downloaded)" )
        
        untagged_photos.each do |photo|
          photo_info = flickr.photos.getInfo(photo_id: photo['id'])
          puts "#{photo.title} - #{photo_info.urls.first._content}"
        end

        untagged_photos.length
      else
        Utils::ColorPrint::red_out("the flickr.photos.getUntagged call did not return any photos")
      end
    end

    #########
    private

    def set_local_auth
      flickr.access_token = Settings.authentication[:token][:access_token]
      flickr.access_secret = Settings.authentication[:token][:access_secret]
      
      begin
        @login = flickr.test.login
        puts "You are now authenticated as #{Utils::ColorPrint::green(@login.username)} with token #{flickr.access_token} and secret #{flickr.access_secret}"
      rescue FlickRaw::FailedResponse => e
        puts "Authentication failed : #{e.msg}"
      end
    end

    def set_basic_auth
      FlickRaw.api_key = Settings.authentication[:api_key]
      FlickRaw.shared_secret = Settings.authentication[:shared_secret]
      
      raise "api_key not set!" unless FlickRaw.api_key
      raise "shared_secret not set!" unless FlickRaw.shared_secret
    end

    def ask_to_open(id)
      info = flickr.photos.getInfo(photo_id: id)
      url = FlickRaw.url_b(info)
      %x(open "#{url}")
      user_url = FlickRaw.url_profile(info)
      %x(open "#{user_url}")
    end

    def load_settings
      filename = "config/ruby-flickr-settings.yml"
      Settings.load!(filename)
      Utils::ColorPrint::green_out("loaded settings at #{filename}")
    end

    def fetch_files(urls, photos_info, dir=nil)
      dir ||= "images-license-#{@license}"
      new_dir = "data/#{dir}"
      Utils::create_dir_if_needed(new_dir)

      Dir.chdir(new_dir) do
        urls.each_with_index do |url, index|
          filename = Utils::sanitize_filename(photos_info[index].title) + ".jpg"
          fetch_file(url, filename)
        end
        Utils::write_files_info(photos_info, urls) 
      end
    end

    def fetch_file(url, filename)
      `wget --wait=1 --no-clobber -O '#{filename}' '#{url}'`
    end
    
    # doesn't write detailed info to a yml file like fetch_files()
    def fetch_just_files(photos, dir)
      dir ||= "temp"
      new_dir = "data/#{dir}"
      Utils::create_dir_if_needed(new_dir)

      Dir.chdir(new_dir) do
        photos.to_a.each_with_index do |photo, index|
          download_name = Utils::sanitize_filename(photo.title) + ".jpg"
          `wget --no-clobber -O '#{download_name}' '#{photo.url_o}'`
        end
      end
    end
  end

end

