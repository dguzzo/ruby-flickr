require 'spec_helper'
require 'flickraw'
require 'ruby-flickr'

describe "ruby_flickr" do
  describe "set_basic_auth" do
    flickraw_basic = nil

    before do
      allow(Settings).to receive_messages(:load! => nil)
    end

    it "sets FlickRaw.api_key and FlickRaw.shared_secret" do
      allow(Settings).to receive_messages(:authentication => {:api_key => 'fake-api-key', :shared_secret => "fake-shared-secret"})
      flickraw_basic = RubyFlickr::API.new
      expect(FlickRaw.api_key).to eq('fake-api-key')
      expect(FlickRaw.shared_secret).to eq('fake-shared-secret')
    end

    it "raises if shared_secret is not present in Settings" do
      allow(Settings).to receive_messages(:authentication => {:api_key => 'fake-api-key'})
      expect{RubyFlickr::API.new}.to raise_error("shared_secret not set!")
    end

    it "raises if api_key is not present in Settings" do
      allow(Settings).to receive_messages(:authentication => {:shared_secret => 'fake-shared-secret'})
      expect{RubyFlickr::API.new}.to raise_error("api_key not set!")
    end
  end

  describe "load_settings" do
    it "should call Settings.load!" do
      allow(Settings).to receive_messages(:authentication => {:api_key => 'fake-api-key', :shared_secret => "fake-shared-secret"}, :load! => nil)
      flickraw_basic = RubyFlickr::API.new
      expect(Settings).to have_received(:load!)
    end
  end

end
