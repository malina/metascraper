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

      response_body = @response.body

      @document = XML.parse_html(response_body)
      get_charset()
      @texts = Parsers::Text.new(@document, config)
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

    private def get_charset : Void
      from_response_charset = (@response.charset || "utf-8").as(String)

      unless charset_from_html.empty?
        config.charset = charset_from_html
      else
        config.charset = from_response_charset
      end
    rescue
      nil
    end

    private def charset_from_html : String
      meta = @document.xpath_node("//meta[contains(@content, 'charset')]/@content")
      if meta
        value = meta.content
        substring = "charset="
        index = value.index(substring).as(Int32)
        value[(index+substring.size)..(value.size-1)]
      else
        ""
      end
    rescue
      ""
    end
  end
end
