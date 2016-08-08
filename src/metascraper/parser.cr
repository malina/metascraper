module Metascraper
  class Parser
    getter texts
    getter response

    delegate title, description, to: @texts
    delegate images, base_url, to: @images

    def initialize(url : String)
      @url = url
      @response = HTTP::Client.get(url)
      @document = XML.parse_html(@response.body)
      @texts = Parsers::Text.new(@document)
      @images = Parsers::Images.new(@document, @url)
    end
  end
end
