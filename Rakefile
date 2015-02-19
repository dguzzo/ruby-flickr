# add all files in /lib to path
$:.unshift File.join(File.dirname(__FILE__), "lib")

require 'ruby-flickr'

task default: ["creative_commons:get_photos_that_allow_derivatives"]


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

  desc "get Attribution License favorite photos"
  task :get_attribution do
    flickr = RubyFlickr::API.new(4) # default
    flickr.get_creative_common_faves
  end

  desc "get Attribution-NoDerivs License favorite photos"
  task :get_attribution_noderivs do
    flickr = RubyFlickr::API.new(6)
    flickr.get_creative_common_faves
  end

  desc "get Attribution-NonCommercial-NoDerivs License favorite photos"
  task :get_attribution_noncom_noderivs do
    flickr = RubyFlickr::API.new(3)
    flickr.get_creative_common_faves
  end
  
  desc "get Attribution-NoCommercial License favorite photos"
  task :get_attribution_noncom do
    flickr = RubyFlickr::API.new(2)
    flickr.get_creative_common_faves
  end

  desc "get Attribution-NonCommercial-ShareAlike License favorite photos"
  task :get_attribution_noncom_share_alike do
    flickr = RubyFlickr::API.new(1)
    flickr.get_creative_common_faves
  end

  desc "get Attribution-ShareAlike License favorite photos"
  task :get_attribution_share_alike do
    flickr = RubyFlickr::API.new(5)
    flickr.get_creative_common_faves
  end

  desc "get no known License favorite photos"
  task :get_no_known_license do
    flickr = RubyFlickr::API.new(7)
    flickr.get_creative_common_faves
  end

  desc "collate all cc fetched images to one directory"
  task :collate_cc_images do
    Utils::collate_cc_files
  end

  desc "get all CC images that allow derivatives"
  task :get_photos_that_allow_derivatives do
    Rake::Task["creative_commons:get_attribution"].invoke #4
    Rake::Task["creative_commons:get_attribution_noncom_share_alike"].invoke #1
    Rake::Task["creative_commons:get_attribution_noncom"].invoke #2
    Rake::Task["creative_commons:get_attribution_share_alike"].invoke #5
    Rake::Task["creative_commons:get_attribution_noncom_share_alike"].invoke #7

    Rake::Task["creative_commons:collate_cc_images"].invoke
  end

end

namespace :my_photos do
  desc "get my photos that are untagged"
  task :get_untagged do
    flickr = RubyFlickr::API.new
    flickr.get_untagged
  end

  desc "get recent photos"
  task :get_recent_public_photos do
    flickr = RubyFlickr::API.new
    flickr.get_recent_public_photos # Returns a list of the latest public photos uploaded to flickr.
  end

  desc "show most recent public photo"
  task :show_most_recent_public_photo do
    flickr = RubyFlickr::API.new
    flickr.show_most_recent_public_photo # Returns a list of the latest public photos uploaded to flickr.
  end

  desc "get my public photos"
  task :get_my_public_photos do
    flickr = RubyFlickr::API.new
    flickr.get_my_public_photos(5)
  end
end

task :console do
  require 'irb'
  require 'irb/completion'
  require 'ruby-flickr'
  ARGV.clear
  IRB.start
end

