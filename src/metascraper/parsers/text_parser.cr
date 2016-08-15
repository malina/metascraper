module Metascraper
  module Parsers
    class Text
      getter document
      def initialize(@document : XML::Node)
      end

      def title
        document_title || og_title
      rescue
        nil
      end

      def description
        meta_descriptions = document.xpath_nodes("//meta[@name='description']")
        unless meta_descriptions.empty?
          meta_descriptions.first.attributes["content"].text
        else
          secondary_description
        end
      rescue
        nil
      end

      def secondary_description
        first_long_paragraph = document.xpath_node("//p[string-length() >= 100]")
        first_long_paragraph ? first_long_paragraph.text : ""
      end

      private def document_title
        title = document.xpath_node("//title")
        title.inner_text
      end

      private def og_title
        title = document.xpath_node("//meta[@property='og:title']")
        title.attributes["content"].text
      end
    end
  end
end
