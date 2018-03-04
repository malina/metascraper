require "./metascraper/*"
require "./metascraper/presenters/*"
require "./metascraper/parsers/content/*"
require "./metascraper/parsers/*"
require "uri"
require "xml"
require "http/client"
alias Candidate = NamedTuple(content_score: Float64, elem: XML::Node)

require "benchmark"

module Metascraper
  def self.new(url : String, options = {} of Symbol => Int32 | Bool)
    Metascraper.config do |config|
      config.url = url
      config.uri = URI.parse(url)
      config.base_url = "#{config.uri.scheme}://#{config.uri.host}/"

      config.image_min_width = options.fetch(:image_min_width) { config.image_min_width }
      config.skip_video = options.fetch(:skip_video) { config.skip_video }
      config.all_image = options.fetch(:all_image) { config.all_image }
    end

    Document.new(url)
  end
end
