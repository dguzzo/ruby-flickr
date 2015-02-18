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
      title = sanitize_filename(photo.title)
      file_path = "#{title}.yml"

      if File.exists?(file_path)
        puts "skipping file-write #{file_path}; it already exists"
      else
        File.open(file_path, 'w') do |file|
          puts "writing file #{Utils::ColorPrint::green(title)}.yml..."
          file.write(custom_photo_info(photo, urls[index]).to_yaml)
        end
      end
    end
  end

  def self.collate_cc_files
    combined_cc_dir = "data/combined-licenses"
    combined_cc_dir_full = File.expand_path(combined_cc_dir, Dir.pwd)
    file_count = 0
    data_dir = "data"
    Utils::create_dir_if_needed(combined_cc_dir)

    dirs = Dir.entries(data_dir).keep_if{|i| i =~ /^images-license-\w/}
    dirs.map! {|dir| File.expand_path(dir, File.join(Dir.pwd, data_dir))}

    puts dirs

    dirs.each do |dir|
      files = Dir.glob("#{dir}/*.{yml,jpg,jpeg}")
      FileUtils.cp(files, combined_cc_dir_full)
      file_count += files.length
    end

    puts "done! moved #{Utils::ColorPrint::green(file_count)} images to #{combined_cc_dir_full}"
  end

end
