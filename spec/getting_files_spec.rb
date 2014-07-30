require 'spec_helper'
require 'flickraw'
require 'ruby-flickr'

describe "getting photos" do
  flickraw_basic = nil

  before :each do
    flickraw_basic = RubyFlickr::API.new
  end

  xit "getting untagged photos sets local auth" do
    flickraw_basic::stub(:set_local_auth)
    flickr.photos::stub(:getUntagged) # stub flickraw's call to the flickr API
    flickraw_basic.should_receive(:set_local_auth)
    flickraw_basic.get_untagged
  end
  
  xit "getting untagged photos doesn't break if zero photos are returned" do
    flickraw_basic::stub(:set_local_auth)
    flickr.photos::stub(:getUntagged).and_return([])
    expect { flickraw_basic.get_untagged }.to_not raise_error
    flickraw_basic.get_untagged.should equal(0)
  end

  xit "getting untagged photos returns count of files found" do
    photo1, photo2 = Object.new, Object.new
    photo1::stub(:title).and_return("asdf")
    photo2::stub(:title).and_return("zxcv")

    flickraw_basic::stub(:set_local_auth)
    flickr.photos::stub(:getUntagged).and_return([photo1, photo2]) # TODO this needs to return a flickraw ResponseList
    flickraw_basic.get_untagged.should equal(2)
  end
end
