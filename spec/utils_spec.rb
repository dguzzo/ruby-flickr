require "ruby-flickr/utils"

describe "utils_spec" do
  describe "sanitize_filename" do
    it "sanitizes properly" do
      expect(Utils::sanitize_filename("something with spaces")).to eq("something_with_spaces")
      expect(Utils::sanitize_filename("something_with_underscores")).to eq("something_with_underscores")
      expect(Utils::sanitize_filename("something-with-dashes")).to eq("something-with-dashes")
      expect(Utils::sanitize_filename("something with an extension.jpg")).to eq("something_with_an_extension.jpg")
      expect(Utils::sanitize_filename("something/with/slashes")).to eq("something_with_slashes")
      expect(Utils::sanitize_filename("something/with//slashes.and.others")).to eq("something_with__slashes.and.others")
      expect(Utils::sanitize_filename("something\with\\backslashes.and.others")).to eq("something\with\\backslashes.and.others")
      expect(Utils::sanitize_filename("something@with!stuff")).to eq("something_with_stuff")

      expect(Utils::sanitize_filename("_something")).to eq("_something")
      expect(Utils::sanitize_filename("'something")).to eq("_something")
      expect(Utils::sanitize_filename("$@something")).to eq("__something")
      expect(Utils::sanitize_filename("*something")).to eq("_something")
    end

    it "returns a canned title for a bad filename" do
      expect(Utils::sanitize_filename(nil)).to eq("bad-file-name")
    end

    it "returns 'untitled' for an empty filename" do
      expect(Utils::sanitize_filename("")).to eq("untitled")
    end

    it "should throw if no filename is passed" do
      expect {Utils::sanitize_filename}.to raise_error(ArgumentError)
    end
  end
  
  describe "custom_photo_info" do
    photo, url = nil
    
    # Flickraw uses metaprogramming to dynamically builds methods from Flickr's API response, and one of these is
    # essentially a list of Photo objects, in the form of FlickRaw::Flickr::Photos, where each Photo object
    # is basically a container for accessible attributes.
    
    # using structs, I'm emulating this to pass into custom_photo_info(). If Flickraw didn't do this, I
    # could get away with just passing in a simple hash
    FauxPhoto = Struct.new(:title, :owner, :urls)
    PhotoOwner = Struct.new(:username, :realname, :nsid)
    PhotoURL = Struct.new(:_content)
    
    before :each do
      photo = FauxPhoto.new("Skyline Sunset Zoomed", PhotoOwner.new("DCZwick", "Doug Zwick", "42468795@N05"), [PhotoURL.new("https://www.flickr.com/photos/dczwick/16278149456/"), PhotoURL.new("some other url")])
      url = "https://farm8.staticflickr.com/7582/16278149456_becda8b2ba_o.jpg"
    end
    
    it "structures the returned data properly, with a realname provided" do
      photo_info = Utils::custom_photo_info(photo, url)
    
      expect(photo_info['titles']['original']).to eq("Skyline Sunset Zoomed")
      expect(photo_info['titles']['sanitized']).to eq("Skyline_Sunset_Zoomed")
      
      expect(photo_info['owner']['username']).to eq("DCZwick")
      expect(photo_info['owner']['realname']).to eq("Doug Zwick")
      expect(photo_info['owner']['nsid']).to eq("42468795@N05")
      expect(photo_info['owner']['profile_page']).to eq("http://www.flickr.com/photos/DCZwick/")
      
      expect(photo_info['urls']['photopage']).to eq("https://www.flickr.com/photos/dczwick/16278149456/")
      expect(photo_info['urls']['largest_size']).to eq("https://farm8.staticflickr.com/7582/16278149456_becda8b2ba_o.jpg")
      
      expect(photo_info['flickr_annotation']['flickr_title']).to eq("Skyline Sunset Zoomed")
      expect(photo_info['flickr_annotation']['flickr_title_photo_page']).to eq("Skyline Sunset Zoomed - https://www.flickr.com/photos/dczwick/16278149456/")
      expect(photo_info['flickr_annotation']['username_profile_page']).to eq("DCZwick - http://www.flickr.com/photos/DCZwick/")
      expect(photo_info['flickr_annotation']['caption_link']).to eq("Skyline Sunset Zoomed by Doug Zwick - https://www.flickr.com/photos/dczwick/16278149456/")
    end

    it "structures the returned data properly, without a realname provided" do
      photo.owner.realname = nil
      photo_info = Utils::custom_photo_info(photo, url)
      expect(photo_info['flickr_annotation']['caption_link']).to eq("Skyline Sunset Zoomed by DCZwick - https://www.flickr.com/photos/dczwick/16278149456/")
    end

  end
  
end
