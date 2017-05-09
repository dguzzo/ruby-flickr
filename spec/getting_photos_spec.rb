require 'spec_helper'
require 'httparty'
require "webmock/rspec"
require 'ruby-flickr'

describe "getting photos" do
  ruby_flickr = nil

  before :each do
    ruby_flickr = RubyFlickr::API.new
    allow(ruby_flickr).to receive_messages(set_local_auth: nil, get_photo_info: nil)

  end

  it "sets local auth when fetching untagged photos" do
    allow(ruby_flickr).to receive_messages(get_untagged_internal: [])
    ruby_flickr.get_untagged
    expect(ruby_flickr).to have_received(:set_local_auth)
  end
  
  it "doesn't raise an error if zero photos are returned when fetching untagged photos" do
    allow(ruby_flickr).to receive_messages(get_untagged_internal: [])
    expect(ruby_flickr.get_untagged).to eq(0)
  end

  it "getting untagged photos returns count of files found" do
    allow(ruby_flickr).to receive_messages(get_untagged_internal: [{id: 'boss'}, {id: 'man'}])
    expect(ruby_flickr.get_untagged).to eq(2)
  end

  describe "fetch_file" do
    it "rescues a Net::ReadTimeout" do
      stub_request(:get, 'http://www.example.net/test.jpg').to_raise(Net::ReadTimeout)
      expect{ruby_flickr.send(:fetch_file, 'http://www.example.net/test.jpg', 'rename.jpg')}.to_not raise_error
      File.delete('rename.jpg') if File.exist?('rename.jpg')
    end

  end

end
