module Metascraper
  struct Videos
    def videos
    end
  end

  class Parser
    getter texts, response, config

    @config = Metascraper.config

    delegate title, description, to: @texts
    delegate images, to: @images
    delegate videos, to: @videos

    def initialize(url : String)
      @url = url
      @response = HTTP::Client.get(url)

      response_body = encode_body

      @document = XML.parse_html(response_body)
      @texts = Parsers::Text.new(@document)
      @images = Parsers::Images.new(@document, config)
      @videos = config.skip_video ? Videos.new : Parsers::Videos.new(@document, config)
    end

    private def encode_body : String
      charset = @response.charset.as(String)

      if charset == config.charset
        @response.body
      else
        config.charset = charset
        Utils.new(
          @response.body,
          charset
        ).encodeToUtf8.as(String)
      end
    end
  end
end
