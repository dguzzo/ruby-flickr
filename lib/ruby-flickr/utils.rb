require 'FileUtils' unless defined?(FileUtils)

module Utils
  module ColorPrint
    def self.green(message)
      "\e[1;32m#{message}\e[0m"
    end

    def self.yellow(message)
      "\e[1;33m#{message}\e[0m"
    end

    def self.cyan(message)
      "\e[1;36m#{message}\e[0m"
    end

    def self.red(message)
      "\e[1;31m#{message}\e[0m"
    end

    def self.green_out(message)
      puts "\e[1;32m#{message}\e[0m"
    end

    def self.yellow_out(message)
      puts "\e[1;33m#{message}\e[0m"
    end

    def self.cyan_out(message)
      puts "\e[1;36m#{message}\e[0m"
    end

    def self.red_out(message)
      puts "\e[1;31m#{message}\e[0m"
    end
  end
  
  def self.create_dir_if_needed(image_dir_name)
    unless File.directory?(image_dir_name)
      puts "creating directory '#{image_dir_name}'..."
      FileUtils.mkdir_p(image_dir_name)
    end
    image_dir_name
  end

  # http://makandracards.com/makandra/1309-sanitize-filename-with-user-input
  def self.sanitize_filename(filename)
    if !filename.is_a?(String)
      badname = "bad-file-name"
      Utils::ColorPrint::red_out("unreadable filename; can't sanitize. file being written with title: #{badname}" )
      return badname
    elsif filename.empty?
      return "untitled"
    end

    filename.gsub(/[^0-9A-z.\-]/, '_')
  end

  def self.write_files_info(photos_info, urls)
    photos_info.each_with_index do |photo, index|
      title = Utils::sanitize_filename(photo.title)
      file_path = "#{title}.yml"

      if File.exists?(file_path)
        puts "skipping file-write #{file_path}; it already exists"
      else
        File.open(file_path, 'w') do |file|
          puts "writing file #{Utils::ColorPrint::green(title)}.yml..."
          file.write(Utils::custom_photo_info(photo, urls[index]).to_yaml)
        end
      end
    end
  end

  def self.custom_photo_info(photo, url)
    {
      "titles" => {
        "original" => photo.title,
        "sanitized" => Utils::sanitize_filename(photo.title)
      },
      "owner" => {
        "username" => photo.owner.username,
        "realname" => photo.owner.realname,
        "nsid" => photo.owner.nsid,
        "profile_page" => "http://www.flickr.com/photos/#{photo.owner.username}/"
      },
      "urls" => {
        "photopage" => photo.urls.first._content,
        "largest_size" => url
      },
      "flickr_annotation" => {
        "flickr_title" => photo.title,
        "flickr_title_photo_page" => "#{photo.title} - #{photo.urls.first._content}",
        "username_profile_page" => photo.owner.username + " - http://www.flickr.com/photos/#{photo.owner.username}/",
        "caption_link" => "#{photo.title} by #{photo.owner.realname || photo.owner.username} - #{photo.urls.first._content}"
      }
    }
  end

  def self.collate_cc_files
    combined_cc_dir = "data/combined-licenses"
    combined_cc_dir_full = File.expand_path(combined_cc_dir, Dir.pwd)
    file_count = 0
    data_dir = "data"

    Utils::create_dir_if_needed(combined_cc_dir)

    dirs = Dir.entries(data_dir).keep_if{|i| i =~ /^images-license-\w/}
    dirs.map! {|dir| File.expand_path(dir, File.join(Dir.pwd, data_dir))}

    dirs.each do |dir|
      files = Dir.glob("#{dir}/*.{yml,jpg,jpeg}")
      FileUtils.cp(files, combined_cc_dir_full)
      file_count += files.length
    end

    puts "done! moved #{Utils::ColorPrint::green(file_count)} images to #{combined_cc_dir_full}"
  end

end
