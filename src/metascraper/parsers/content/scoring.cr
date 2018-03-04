module Metascraper
  module Parsers
    module Content
      class Scoring
        ELEMENT_SCORES = {
          "div" => 5,
          "blockquote" => 3,
          "form" => -3,
          "th" => -5
        }

        REGEXES = {
          positive: /article|body|content|entry|hentry|main|page|pagination|post|text|blog|story/i,
          negative: /combx|comment|com-|contact|foot|footer|footnote|masthead|media|meta|outbrain|promo|related|scroll|shoutbox|sidebar|sponsor|shopping|tags|tool|widget/i,
        }

        def self.score_node(elem : XML::Node?, @@weight_classes : Bool) : Float64
          content_score = class_weight(elem)
          content_score += elem ? ELEMENT_SCORES.fetch(elem.name.downcase, 0) : 0
          content_score
        end

        def self.class_weight(e : XML::Node?) : Float64
          weight = 0.0
          return weight unless @@weight_classes
          return weight unless e

          if e.attributes["class"]? && e.attributes["class"].content != ""
            weight -= 25 if e.attributes["class"].content =~ REGEXES[:negative]
            weight += 25 if e.attributes["class"].content =~ REGEXES[:positive]
          end

          if e.attributes["id"]? && e.attributes["id"].content != ""
            weight -= 25 if e.attributes["id"].content =~ REGEXES[:negative]
            weight += 25 if e.attributes["id"].content =~ REGEXES[:positive]
          end

          weight
        end

        def self.get_link_density(elem : XML::Node) : Float64
          link_length = elem.xpath_nodes("//a").map{|e| e.text }.join("").size.to_f
          text_length = elem.text.size.to_f
          link_length / text_length
        end
      end
    end
  end
end
