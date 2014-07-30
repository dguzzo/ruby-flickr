require 'spec_helper'
require 'flickraw'
require './vendor/deep_symbolize'
require './vendor/settings'
require 'ruby-flickr'

describe "ruby_flickr" do
  describe "set_basic_auth" do
    flickraw_basic = nil

    before do
      Settings::stub(:load!)
    end

    it "sets FlickRaw.api_key and FlickRaw.shared_secret" do
      Settings::stub(:authentication).and_return({:api_key => 'fake-api-key', :shared_secret => "fake-shared-secret"})
      flickraw_basic = RubyFlickr::API.new
      expect(FlickRaw.api_key).to eq('fake-api-key')
      expect(FlickRaw.shared_secret).to eq('fake-shared-secret')
    end

    it "doesn't set FlickRaw.shared_secret if not present in Settings" do
      Settings::stub(:authentication).and_return({:api_key => 'fake-api-key'})
      flickraw_basic = RubyFlickr::API.new
      expect(FlickRaw.api_key).to eq('fake-api-key')
      expect(FlickRaw.shared_secret).to be_nil
    end

    it "doesn't set FlickRaw.api_key if not present in Settings" do
      Settings::stub(:authentication).and_return({:shared_secret => 'fake-shared-secret'})
      flickraw_basic = RubyFlickr::API.new
      expect(FlickRaw.shared_secret).to eq('fake-shared-secret')
      expect(FlickRaw.api_key).to be_nil
    end
  end

  describe "load_settings" do
    it "should call Settings.load!" do
      Settings::stub(:authentication).and_return({:api_key => 'fake-api-key', :shared_secret => "fake-shared-secret"})
      Settings::stub(:load!)
      flickraw_basic = RubyFlickr::API.new
      expect(Settings).to have_received(:load!)
    end
  end

  describe "sanitize_filename" do
    flickraw_basic = nil
    before :each do
      flickraw_basic = RubyFlickr::API.new
    end

    it "sanitizes properly" do
      #testing a private method
      expect(flickraw_basic.send(:sanitize_filename, "something with spaces")).to eq("something_with_spaces")
      expect(flickraw_basic.send(:sanitize_filename, "something_with_underscores")).to eq("something_with_underscores")
      expect(flickraw_basic.send(:sanitize_filename, "something-with-dashes")).to eq("something-with-dashes")
      expect(flickraw_basic.send(:sanitize_filename, "something with an extension.jpg")).to eq("something_with_an_extension.jpg")
      expect(flickraw_basic.send(:sanitize_filename, "something/with/slashes")).to eq("something_with_slashes")
      expect(flickraw_basic.send(:sanitize_filename, 'something/with//slashes.and.others')).to eq('something_with__slashes.and.others')
      expect(flickraw_basic.send(:sanitize_filename, "something@with!stuff")).to eq("something_with_stuff")
    end

    it "returns a canned title for a bad filename" do
      expect(flickraw_basic.send(:sanitize_filename, nil)).to eq("bad-file-name")
    end

    it "returns 'untitled' for a missing filename" do
      expect(flickraw_basic.send(:sanitize_filename, "")).to eq("")
    end

    it "should throw if no filename is passed" do
      expect {flickraw_basic.send(:sanitize_filename)}.to raise_error(ArgumentError)
    end
  end
end
