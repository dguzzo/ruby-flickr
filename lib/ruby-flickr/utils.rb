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
end
