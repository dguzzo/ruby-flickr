module Utils
  module ColorPrint
    def self.green(message)
      "\e[1;32m#{message}\e[0m"
    end

    def self.yellow(message)
      "\e[1;33m#{message}\e[0m"
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

    def self.red_out(message)
      puts "\e[1;31m#{message}\e[0m"
    end
  end
  
  def self.create_dir_if_needed(image_dir_name)
    unless File.directory?(image_dir_name)
      puts "creating directory '#{image_dir_name}'..."
      Dir.mkdir(image_dir_name)
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
      info_dir = nil #'photo-info/'
      Utils::create_dir_if_needed(info_dir) if info_dir
      title = sanitize_filename(photo.title)
      file_path = "#{info_dir}#{title}.yml"

      if File.exists?(file_path)
        puts "skipping file-write #{file_path}; it already exists"
      else
        File.open(file_path, 'w') do |file|
          puts Dir.pwd
          puts "writing file #{Utils::ColorPrint::green(title)}.yml..."
          file.write(custom_photo_info(photo, urls[index]).to_yaml)
        end
      end
    end
  end

end
