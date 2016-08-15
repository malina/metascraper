module Metascraper
  class Parser
    getter texts, response, config

    @config = Metascraper.config

    delegate title, description, to: @texts
    delegate images, base_url, to: @images

    def initialize(url : String)
      @url = url
      @response = HTTP::Client.get(url)

      response_body = encode_body

      @document = XML.parse_html(response_body)
      @texts = Parsers::Text.new(@document)
      @images = Parsers::Images.new(@document, config)
    end

    private def encode_body : String
      charset = @response.charset as String
      
      if charset == config.charset
        @response.body
      else
        config.charset = charset
        Utils.new(
          @response.body,
          charset
        ).encodeToUtf8 as String
      end
    end
  end
end
