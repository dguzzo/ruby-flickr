require 'ruby-flickr'

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
        test = RubyFlickr.new
        test.get_creative_common_faves(5) #default
    end
    
    desc "get Attribution-NonCommercial-ShareAlike License favorite photos"
    task :get_attribution_noncom_share_alike do
        test = RubyFlickr.new
        test.get_creative_common_faves(1)
    end
    
    desc "get Attribution-NonCommercial-NoDerivs License favorite photos"
    task :get_attribution_noncom_noderivs do
        test = RubyFlickr.new
        test.get_creative_common_faves(3)
    end
    
    desc "get my photos that are untagged"
    task :get_untagged do
        test = RubyFlickr.new
        test.get_untagged
    end
    
    desc "get recent photos"
    task :get_recent do
        test = RubyFlickr.new
        test.get_recent
    end
    
    desc "get my public photos"
    task :get_my_public_photos do
        test = RubyFlickr.new
        test.get_my_public_photos
    end
end
