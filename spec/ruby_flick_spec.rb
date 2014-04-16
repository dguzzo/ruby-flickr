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
          FlickRaw.api_key.should eq('fake-api-key')
          FlickRaw.shared_secret.should eq('fake-shared-secret')
        end

        it "doesn't set FlickRaw.shared_secret if not present in Settings" do
          Settings::stub(:authentication).and_return({:api_key => 'fake-api-key'})
          flickraw_basic = RubyFlickr::API.new
          FlickRaw.api_key.should eq('fake-api-key')
          FlickRaw.shared_secret.should be_nil
        end

        it "doesn't set FlickRaw.api_key if not present in Settings" do
          Settings::stub(:authentication).and_return({:shared_secret => 'fake-shared-secret'})
          flickraw_basic = RubyFlickr::API.new
          FlickRaw.shared_secret.should eq('fake-shared-secret')
          FlickRaw.api_key.should be_nil
        end
    end
    
    describe "load_settings" do
      it "should call Settings.load!" do
        Settings::stub(:authentication).and_return({:api_key => 'fake-api-key', :shared_secret => "fake-shared-secret"})
        Settings.should_receive(:load!)
        flickraw_basic = RubyFlickr::API.new
      end
    end
    
    describe "sanitize_filename" do
      flickraw_basic = nil
      before :each do
        flickraw_basic = RubyFlickr::API.new
      end
      
      it "sanitizes properly" do
        #testing a private method
        flickraw_basic.send(:sanitize_filename, "something with spaces").should eq("something_with_spaces")
        flickraw_basic.send(:sanitize_filename, "something_with_underscores").should eq("something_with_underscores")
        flickraw_basic.send(:sanitize_filename, "something-with-dashes").should eq("something-with-dashes")
        flickraw_basic.send(:sanitize_filename, "something with an extension.jpg").should eq("something_with_an_extension.jpg")
        flickraw_basic.send(:sanitize_filename, "something/with/slashes").should eq("something_with_slashes")
        flickraw_basic.send(:sanitize_filename, 'something/with//slashes.and.others').should eq('something_with__slashes.and.others')
        flickraw_basic.send(:sanitize_filename, "something@with!stuff").should eq("something_with_stuff")
      end
      
      it "returns a canned title for a bad filename" do
          flickraw_basic.send(:sanitize_filename, nil).should eq("bad-file-name")
      end
      
      it "returns 'untitled' for a missing filename" do
          flickraw_basic.send(:sanitize_filename, "").should eq("")
      end
      
      it "should throw if no filename is passed" do
        expect {flickraw_basic.send(:sanitize_filename)}.to raise_error(ArgumentError)
      end
    end
    
end
