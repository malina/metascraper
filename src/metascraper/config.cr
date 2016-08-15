module Metascraper
  class Config
    INSTANCE = Config.new

    property min_width, base_url, url, uri

    def initialize
      @min_width = 500
      @url = ""
      @base_url = ""
      @uri = URI.new
    end
  end

  def self.config
    yield Config::INSTANCE
  end

  def self.config
    Config::INSTANCE
  end
end
