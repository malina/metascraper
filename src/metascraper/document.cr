module Metascraper
  class Document
    METHODS = %i(title)
    getter url
    getter parser
    delegate title, description, to: @parser
    delegate images, base_url, to: @parser

    def initialize(url : String)
      @url = url
      @parser = Parser.new(url)
    end

    def to_hash
      {
        "url"           => url,
        "title"         => title,
        "description"   => description,
        "images" => images
      }
    end
  end
end
