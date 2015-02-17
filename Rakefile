# add all files in /lib to path
$:.unshift File.join(File.dirname(__FILE__), "lib")

require 'ruby-flickr'

namespace :build do
  desc "create settings file"
  task :create_settings do
    File.copy_stream("config/sample_settings.yml", "config/ruby-flickr-settings.yml")
  end
end

# 0 => "All Rights Reserved",
# 4 => "Attribution License",
# 6 => "Attribution-NoDerivs License",
# 3 => "Attribution-NonCommercial-NoDerivs License",
# 2 => "Attribution-NonCommercial License",
# 1 => "Attribution-NonCommercial-ShareAlike License",
# 5 => "Attribution-ShareAlike License",
# 7 => "No known copyright restrictions",
# 8 => "United States Government Work",

namespace :creative_commons do
  desc "get Attribution-ShareAlike License favorite photos"
  task :get_attribution_share_alike do
    test = RubyFlickr::API.new(5) # default
    test.get_creative_common_faves
  end

  desc "get Attribution-NonCommercial-ShareAlike License favorite photos"
  task :get_attribution_noncom_share_alike do
    test = RubyFlickr::API.new(1)
    test.get_creative_common_faves
  end

  desc "get Attribution-NonCommercial-NoDerivs License favorite photos"
  task :get_attribution_noncom_noderivs do
    test = RubyFlickr::API.new(3)
    test.get_creative_common_faves
  end

  desc "get my photos that are untagged"
  task :get_untagged do
    test = RubyFlickr::API.new
    test.get_untagged
  end

  desc "get recent photos"
  task :get_recent do
    test = RubyFlickr::API.new
    test.get_recent # Returns a list of the latest public photos uploaded to flickr.
  end

  desc "get my public photos"
  task :get_my_public_photos do
    test = RubyFlickr::API.new
    test.get_my_public_photos
  end
end
