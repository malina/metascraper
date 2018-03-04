@[Link("xml2")]
lib LibXML
  fun xmlAddChildList(parent : Node*, node : Node*) : Node*
end

struct XML::Node
  def add(other : XML::Node)
    LibXML.xmlAddChildList(@node.value.children, other.@node.value.children)
  end
end

module Metascraper
  module Parsers
    class ContentParser
      getter document, config
      def initialize(document : XML::Node, @config : Config)
        @document = document.xpath_nodes("//body").first.dup.as(XML::Node)
        @candidates = [] of Candidate
        @best_candidate = { content_score: 0.0, elem: document }
        @candidate_finder = Content::CandidatesFinder.new(@document)
        @sanitizer = Content::Sanitizer.new
      end

      def encode(text : String | Nil) : String | Nil
        return unless text
        Utils.new(text, config.charset).encodeToUtf8.as(String)
      end

      def content
        @candidate_finder.prepare_candidates
        @candidates = @candidate_finder.candidates
        @best_candidate = @candidate_finder.best_candidate

        article = get_article(@candidates, @best_candidate)
        cleaned = @sanitizer.sanitize(article, @candidates, config.charset)
        if article.text.strip.size < 250
          if @candidate_finder.remove_unlikely_candidates
            @candidate_finder.remove_unlikely_candidates = false
          elsif @candidate_finder.weight_classes
            @candidate_finder.weight_classes = false
          elsif @sanitizer.clean_conditionally
            @sanitizer.clean_conditionally = false
          else
            return cleaned
          end
          content
        else
          return cleaned
        end
      end

      def get_article(candidates : Array(Candidate), best_candidate : Candidate) : XML::Node
        sibling_score_threshold = [10, best_candidate[:content_score] * 0.2].max
        output = XML.parse("<?xml version='1.0' encoding='#{config.charset}'?><div>оллл</div>").as(XML::Node)

        result = [] of XML::Node
        node = best_candidate[:elem].parent.as(XML::Node)
        node.children.each do |sibling|
          append = false
          append = true if sibling == best_candidate[:elem]
          candidate = candidates.find do |c|
            c[:elem] == sibling
          end
          append = true if candidate && candidate[:content_score] >= sibling_score_threshold

          if sibling.name.downcase == "p"
            link_density = Content::Scoring.get_link_density(sibling)
            node_content = sibling.text
            node_length = node_content.size

            append = if node_length > 80 && link_density < 0.25
              true
            elsif node_length < 80 && link_density == 0 && node_content =~ /\.( |$)/
              true
            end
          end

          if append
            sibling_dup = sibling.dup
            sibling_dup.name = "div" unless %w[div p].includes?(sibling.name.downcase)
            output.add sibling_dup
          end
        output
      end
    end
  end
end
