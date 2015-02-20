ruby-flickr
===========

use [FlickRaw](http://hanklords.github.io/flickraw/) gem to access Flickr API

# Config

TODO
* obtain Flickr API key and secret
* place them in config/ruby-flickr-settings.yml
TODO

# Running

```bash
gem install ruby-flickr
```

```ruby
require 'ruby-flickr'

test = RubyFlickr::API.new(5) # default license
test.get_creative_common_faves

test = RubyFlickr::API.new
test.get_untagged

test = RubyFlickr::API.new
test.get_my_public_photos
```

# Feedback
Comments on the sanity of my code—either general or specific—are **extremely** welcomed.
