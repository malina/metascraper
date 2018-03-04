module Metascraper
  module Parsers
    module Content
      class CandidatesFinder
        REGEXES = {
          unlikely_candidates: /combx|comment|community|disqus|extra|foot|header|menu|remark|rss|shoutbox|sidebar|sponsor|ad-break|agegate|pagination|pager|popup/,
          maybe_candidates: /and|article|body|column|main|shadow/,
          div_to_p: /<(a|blockquote|dl|div|img|ol|p|pre|table|ul)/i,
          positive: /article|body|content|entry|hentry|main|page|pagination|post|text|blog|story/i,
          negative: /combx|comment|com-|contact|foot|footer|footnote|masthead|media|meta|outbrain|promo|related|scroll|shoutbox|sidebar|sponsor|shopping|tags|tool|widget/i,
        }

        getter document, weight_classes, candidates, best_candidate, remove_unlikely_candidates
        setter weight_classes, remove_unlikely_candidates
        def initialize(@document : XML::Node)
          @candidates = [] of Candidate
          @best_candidate = { content_score: 0.0, elem: @document }
          @weight_classes = true
          @remove_unlikely_candidates = true
        end

        def prepare_candidates
          document.xpath_nodes("//script | //style | //form").each { |i| i.unlink }
          if @remove_unlikely_candidates
            remove_unlikely_candidates!
            transform_misused_divs_into_paragraphs!
          end

          find_candidates
          find_best
        end

        def transform_misused_divs_into_paragraphs!
          document.xpath_nodes("//*").each do |elem|
            if elem.name.downcase == "div"
              if elem.to_s.match(REGEXES[:div_to_p])
                elem.name = "p"
              end
            end
          end
        end

        def remove_unlikely_candidates!
          document.xpath_nodes("//*").each do |elem|
            eclass = elem.attributes["class"]? ? elem.attributes["class"].content : ""
            eid = elem.attributes["id"]? ? elem.attributes["id"].content : ""
            next if eclass.size == 0 && eid.size == 0
            str = "#{eclass}#{eid}"
            if str.match(REGEXES[:unlikely_candidates]) && !str.match(REGEXES[:maybe_candidates]) && (elem.name.downcase != "html") && (elem.name.downcase != "body")
              elem.unlink
            end
          end
        end

        def find_candidates
          min_text_length = 25
          document.xpath_nodes("//p | //td").each do |elem|
            inner_text = elem.text
            next if inner_text.size < min_text_length


            content_score = 1
            content_score += inner_text.split(',').size
            content_score += [(inner_text.size / 100).to_i, 3].min

            if elem.parent
              parent = elem.parent.as(XML::Node)
              score = Scoring.score_node(parent, @weight_classes)
              score += content_score
              candidate = { content_score: score, elem: parent }
              unless candidates.find { |c| c == candidate }
                candidates.push(candidate)
              end
            end

            if elem.parent && elem.parent.responds_to?(:parent)
              parent = elem.parent.as(XML::Node)
              next unless parent.try(&.parent)
              g_parent = parent.parent.as(XML::Node)
              score = Scoring.score_node(g_parent, @weight_classes)
              score += content_score
              candidate = { content_score: score, elem: g_parent }
              unless candidates.find { |c| c == candidate }
                candidates.push(candidate)
              end
            end
          end

          @candidates = candidates.map do |item|
            content_score = item[:content_score] * (1 - Scoring.get_link_density(item[:elem]))
            { content_score: content_score, elem: item[:elem] }
          end
        end

        def find_best
          sorted_candidates = candidates.sort { |a, b| b[:content_score] <=> a[:content_score] }
          return if sorted_candidates.size == 0
          @best_candidate = sorted_candidates[0] || best_candidate
        end
      end
    end
  end
end
