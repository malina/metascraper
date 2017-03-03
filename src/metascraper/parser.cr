module Metascraper
  struct Videos
    def videos
      [] of Metascraper::Presenters::Video
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
      @response = get_request(url).as(HTTP::Client::Response)

      response_body = encode_body

      @document = XML.parse_html(response_body)
      @texts = Parsers::Text.new(@document)
      @images = Parsers::Images.new(@document, config)
      @videos = config.skip_video ? Videos.new : Parsers::Videos.new(@document, config)
    end

    def get_request(url) : HTTP::Client::Response
      response = HTTP::Client.get(url)
      if (300..399).includes?(response.status_code)
        url = response.headers["Location"]
        response = get_request(url)
      end
      response
    end

    private def encode_body : String
      charset = @response.charset.as(String) rescue Metascraper::Config::DEFAULT_CHARSET

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
