module Metascraper
  module Parsers
    class Text
      getter document, config
      def initialize(@document : XML::Node, @config : Config)
      end

      def title
        encode(document_title || og_title)
      rescue
        nil
      end

      def description
        meta_descriptions = document.xpath_nodes("//meta[@name='description']")
        description = unless meta_descriptions.empty?
                        meta_descriptions.first.attributes["content"].text.strip.chomp
                      else
                        secondary_description
                      end
        encode(description)
      rescue
        nil
      end

      def secondary_description
        first_long_paragraph = document.xpath_node("//p[string-length() >= 100] | //div[string-length() >= 100]")
        first_long_paragraph ? first_long_paragraph.text.strip.chomp : ""
      end

      private def document_title
        title = document.xpath_node("//title").as(XML::Node)
        title.inner_text.strip.chomp
      rescue
        nil
      end

      private def og_title
        title = document.xpath_node("//meta[@property='og:title']").as(XML::Node)
        title.attributes["content"].text.strip.chomp
      rescue
        nil
      end

      def encode(text : String | Nil) : String | Nil
        return unless text
        Utils.new(text, config.charset).encodeToUtf8.as(String)
      end
    end
  end
end
