require "./metascraper/*"
require "./metascraper/parsers/*"
require "uri"
require "xml"
require "http/client"

module Metascraper
  def self.new(url : String, options = {} of Symbol => String | Int32)
    Metascraper.config do |config|
      config.url = url
      config.uri = URI.parse(url)
      config.base_url = "#{config.uri.scheme}://#{config.uri.host}/"

      if options.has_key?(:min_width)
        config.min_width = options[:min_width]
      end
    end

    Document.new(url)
  end
end
