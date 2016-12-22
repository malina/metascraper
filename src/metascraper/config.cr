module Metascraper
  class Config
    INSTANCE = Config.new
    DEFAULT_CHARSET = "utf-8"

    property image_min_width, base_url, url, uri, charset, skip_video, all_image

    def initialize
      @image_min_width = 500.as(Bool | Int32)
      @url = ""
      @base_url = ""
      @uri = URI.new
      @charset = DEFAULT_CHARSET
      @skip_video = false.as(Bool | Int32)
      @all_image = false.as(Bool | Int32)
    end
  end

  def self.config
    yield Config::INSTANCE
  end

  def self.config
    Config::INSTANCE
  end
end
