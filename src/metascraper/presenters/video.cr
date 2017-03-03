require "json"
module Metascraper
  module Presenters
    struct Video
      getter source, id
      delegate url, title, description, to: @texts

      def initialize(@id : String, @source : Document)
      end

      def to_hash
        {
          "url"           => source.url,
          "title"         => source.title,
          "description"   => source.description,
          "images" => source.images,
          "html" => html
        }
      end
      
      def html
        "<iframe src='https://www.youtube.com/embed/#{id}?feature=oembed' frameborder='0' allowfullscreen</iframe>"
      end
    end
  end
end
