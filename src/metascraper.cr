require "./metascraper/*"
require "./metascraper/parsers/*"
require "uri"
require "xml"
require "http/client"


module Metascraper
  def self.new(url : String)
    Document.new(url)
  end
end
