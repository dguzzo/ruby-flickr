require 'spec_helper'
require 'flickraw'
require_relative '../vendor/deep_symbolize.rb'
require_relative '../vendor/settings.rb'
require_relative '../lib/flickraw_basic.rb'

describe "ruby_flickr" do
    describe "set_basic_auth" do
        flickraw_basic = nil

        before do
          Settings::stub(:load!)
        end

        it "sets FlickRaw.api_key and FlickRaw.shared_secret" do
          Settings::stub(:authentication).and_return({:api_key => 'fake-api-key', :shared_secret => "fake-shared-secret"})
          flickraw_basic = FlickrawBasic.new
          FlickRaw.api_key.should eq('fake-api-key')
          FlickRaw.shared_secret.should eq('fake-shared-secret')
        end

        it "doesn't set FlickRaw.shared_secret if not present in Settings" do
          Settings::stub(:authentication).and_return({:api_key => 'fake-api-key'})
          flickraw_basic = FlickrawBasic.new
          FlickRaw.api_key.should eq('fake-api-key')
          FlickRaw.shared_secret.should be_nil
        end

        it "doesn't set FlickRaw.api_key if not present in Settings" do
          Settings::stub(:authentication).and_return({:shared_secret => 'fake-shared-secret'})
          flickraw_basic = FlickrawBasic.new
          FlickRaw.shared_secret.should eq('fake-shared-secret')
          FlickRaw.api_key.should be_nil
        end
    end
    
    describe "load_settings" do
      it "should call Settings.load!" do
        Settings::stub(:authentication).and_return({:api_key => 'fake-api-key', :shared_secret => "fake-shared-secret"})
        Settings.should_receive(:load!)
        flickraw_basic = FlickrawBasic.new
      end
    end
end
