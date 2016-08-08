module Metascraper
  module Parsers
    class Images
      getter document, base_url
      @base_url = ""

      def initialize(document : XML::Node, url : String)
        @document = document
        @base_url = base_url(url)
      end

      def images
        images = parsed_images.dup
        images.unshift(og_images) if og_images
        images
      end

      def og_images
        title = document.xpath_node("//meta[@property='og:image']")
        if title
          absolutify(title.attributes["content"].text)
        else
          nil
        end
      rescue
        nil
      end

      private def parsed_images
        document.xpath_nodes("//img/@src").map do |img|
          absolutify(img.text)
        end
      end

      private def base_url(url) : String
        uri = URI.parse(url)
        "#{uri.scheme}://#{uri.host}/"
      end

      private def absolutify(url)
        if url =~ /^\w*\:/i
          url
        else
          [base_url, url].join("")
        end
      rescue
        nil
      end
    end
  end
end
