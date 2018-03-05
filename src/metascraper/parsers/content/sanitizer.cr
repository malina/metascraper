module Metascraper
  module Parsers
    module Content
      class Sanitizer
        getter clean_conditionally
        setter clean_conditionally
        def initialize
          @clean_conditionally = true
        end

        def encode(text : String | Nil, charset : String) : String | Nil
          return unless text
          Utils.new(text, charset).encodeToUtf8.as(String)
        end

        def sanitize(node : XML::Node, candidates : Array(Candidate), charset : String) : String?
          node.xpath_nodes("//h1 | //h2 | //h3 | //h4 | //h5 | //h6").each do |header|
            header.unlink if Scoring.class_weight(header) < 0 || Scoring.get_link_density(header) > 0.33
          end

          node.xpath_nodes("//form | //object | //iframe | //embed | //button | //head").each do |elem|
            elem.unlink
          end

          node.xpath_nodes("//p").each do |elem|
            elem.unlink if elem.content.strip.empty?
          end

          clean_conditionally(node, candidates, "//table | //ul | //div")
          #| //header | //p


          node.xpath_nodes("//*").each do |child|
            child.attributes.each do |a|
                next unless %w(onclick style id class).includes?(a.name.downcase)
              child.attributes[a.name] = ""
            end
          end

          save_opts = XML::SaveOptions::NO_DECL | XML::SaveOptions::NO_EMPTY | XML::SaveOptions::AS_HTML
          html = node.to_xml(options: save_opts)
          return encode(html.gsub(/[\r\n\f]+/, "\n" ), charset)
        end

        def clean_conditionally(node : XML::Node, candidates : Array(Candidate), selector : String)
          return unless @clean_conditionally
          node.xpath_nodes(selector).each do |el|
            weight = Scoring.class_weight(el)
            candidate = candidates.find { |c| c[:elem] == el }
            content_score =  candidate ? candidate[:content_score] : 0
            name = el.name.downcase

            if weight + content_score < 0
              el.unlink
            elsif el.text.count(",") < 10
              counts = {} of String => Int32
              %w[p img li a embed input].map { |kind| counts[kind] = el.xpath_nodes(kind).size }
              counts["li"] -= 100

              # For every img under a noscript tag discount one from the count to avoid double counting
              noscripts = el.xpath_nodes("//noscript")
              if noscripts
                size = 0
                noscripts.each { |n| size += n.xpath_nodes("//img").size }
                counts["img"] -= size
              end

              content_length = el.text.strip.size  # Count the text length excluding any surrounding whitespace
              link_density = Scoring.get_link_density(el)

              reason = clean_conditionally_reason?(name, counts, content_length, weight, link_density)
              if reason
                el.unlink
              end
            end
          end
        end

        def clean_conditionally_reason?(name : String, counts : Hash(String, Int32), content_length : Int32, weight : Float64, link_density : Float64) : String?
          if (counts["img"] > counts["p"]) && (counts["img"] > 1)
            "too many images"
          elsif counts["li"] > counts["p"] && name != "ul" && name != "ol"
            "more <li>s than <p>s"
          elsif counts["input"] > (counts["p"] / 3).to_i
            "less than 3x <p>s than <input>s"
          elsif weight < 25 && link_density > 0.2
            "too many links for its weight (#{weight})"
          elsif weight >= 25 && link_density > 0.5
            "too many links for its weight (#{weight})"
          elsif (counts["embed"] == 1 && content_length < 75) || counts["embed"] > 1
            "<embed>s with too short a content length, or too many <embed>s"
          else
            nil
          end
        end
      end
    end
  end
end
