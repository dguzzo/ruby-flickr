require 'spec_helper'
require 'flickraw'
require 'ruby-flickr'

describe "getting photos" do
  flickraw_basic = nil

  before :each do
    flickraw_basic = RubyFlickr::API.new
  end

  it "getting untagged photos sets local auth" do
    allow(flickraw_basic).to receive_messages(:set_local_auth => nil)
    allow(flickr.photos).to receive_messages(:getUntagged => nil) # stub flickraw's call to the flickr API
    flickraw_basic.get_untagged
    expect(flickraw_basic).to have_received(:set_local_auth)
  end
  
  it "getting untagged photos doesn't raise an error if zero photos are returned" do
    allow(flickraw_basic).to receive_messages(:set_local_auth => nil)
    allow(flickr.photos).to receive_messages(:getUntagged => [])
    expect {flickraw_basic.get_untagged}.to_not raise_error
    expect(flickraw_basic.get_untagged).to eq(0)
  end

  it "getting untagged photos returns count of files found" do
    sample_photo_1 = FlickRaw::Response.new({"id"=>"15660294718",  "owner"=>"49782305@N02",  "secret"=>"37779b2136",  "server"=>"8633",  "farm"=>9,  "title"=>"The Lonely Wild @ Tiny Telephone Recording",  "ispublic"=>1,  "isfriend"=>0,  "isfamily"=>0}, 'photo')
    sample_photo_2 = FlickRaw::Response.new({"id"=>"15661798599", "owner"=>"49782305@N02", "secret"=>"27e6000e35", "server"=>"8589", "farm"=>9, "title"=>"The Lonely Wild @ Tiny Telephone Recording", "ispublic"=>1, "isfriend"=>0, "isfamily"=>0}, 'photo')
    
    DATA = [{"page"=>1,
     "pages"=>1,
     "perpage"=>2,
     "total"=>"2",
     "photo"=>
      [sample_photo_1,
       sample_photo_2]},
     "photos",
     [sample_photo_1,
      sample_photo_2]]
    
    sample_response = FlickRaw::ResponseList.new(*DATA)
    allow(flickraw_basic).to receive_messages(:set_local_auth => nil)
    allow(flickr.photos).to receive_messages(:getUntagged => sample_response)
    temp = flickraw_basic.get_untagged
    expect(temp).to eq(2)
  end
end
