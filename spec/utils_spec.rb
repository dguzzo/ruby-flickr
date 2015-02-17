require "ruby-flickr/utils"

describe "utils_spec" do
  describe "sanitize_filename" do
    flickraw_basic = nil

    before :each do
      flickraw_basic = RubyFlickr::API.new
    end

    it "sanitizes properly" do
      #testing a private method
      expect(Utils::sanitize_filename("something with spaces")).to eq("something_with_spaces")
      expect(Utils::sanitize_filename("something_with_underscores")).to eq("something_with_underscores")
      expect(Utils::sanitize_filename("something-with-dashes")).to eq("something-with-dashes")
      expect(Utils::sanitize_filename("something with an extension.jpg")).to eq("something_with_an_extension.jpg")
      expect(Utils::sanitize_filename("something/with/slashes")).to eq("something_with_slashes")
      expect(Utils::sanitize_filename("something/with//slashes.and.others")).to eq("something_with__slashes.and.others")
      expect(Utils::sanitize_filename("something@with!stuff")).to eq("something_with_stuff")
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
end
