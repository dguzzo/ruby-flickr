ruby-flickr
===========

use FlickRaw gem to access Flickr API

# Running

```ruby
test = RubyFlickr::API.new(5) # default license
test.get_creative_common_faves

test = RubyFlickr::API.new
test.get_untagged

test = RubyFlickr::API.new
test.get_my_public_photos
```

# Feedback
Comments on the sanity of my code—either general or specific—are **extremely** welcomed.
