module Metascraper
  module Parsers
    class Videos
      PROVIDERS = {
        "youtube" => {
          "base_url" => "https://www.youtube.com/watch?v="
        }
      }

      getter document, config

      def initialize(@document : XML::Node, @config : Config)
      end

      def videos
        youtube_urls.map do |url|
          page = Metascraper.new(url, {skip_video: true }).as(Document)
          Metascraper::Presenters::Video.new(url, page)
        end.as(Array(Metascraper::Presenters::Video))
      end

      def youtube_urls : Array(String)
        get_youtube_ids.map do |id|
          [PROVIDERS["youtube"]["base_url"], id].join()
        end
      end

      private def get_youtube_ids
        document.xpath_nodes("//iframe[contains(@src, 'youtube')]/@src").map do |frame|
          source = frame.text.as(String)
          source.split("/").last
        end.uniq.compact
      end
    end
  end
end
