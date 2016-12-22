module Metascraper
  module Parsers
    class Images
      getter document, config

      def initialize(@document : XML::Node, @config : Config)
      end

      def images
        images = parsed_images.dup
        images.unshift(og_images) if og_images
        images.uniq
      end

      def og_images
        title = document.xpath_node("//meta[@property='og:image']")
        if title
          absolutify(title.attributes["content"].text.as(String))
        else
          nil
        end
      rescue
        nil
      end

      private def parsed_images
        path = if config.all_image
                 "//img/@src"
               else
                 "//img[@width >= #{config.image_min_width} or substring-before(@width, 'px') > #{config.image_min_width}]/@src"
               end
        document.xpath_nodes(path).map do |img|
          source = img.text.as(String)
          absolutify(source)
        end
      end

      private def absolutify(url : String)
        if url.starts_with?("//")
          [config.uri.scheme, url].join(":")
        elsif url =~ /^\w*\:/i
          url
        else
          [config.base_url, url].join("")
        end
      rescue
        nil
      end
    end
  end
end
