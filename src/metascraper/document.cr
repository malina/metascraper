module Metascraper
  class Document
    METHODS = %i(title)
    getter url
    getter parser
    delegate title, description, to: @parser
    delegate images, videos, to: @parser

    def initialize(url : String)
      @url = url
      @parser = Parser.new(url)
    end

    def to_hash
      {
        "url"           => url,
        "title"         => title,
        "description"   => description,
        "images" => images,
        "videos" => videos
      }
    end

    def to_json
      string = JSON.build do |json|
        json.object do
          json.field "url", url
          json.field "title", title
          json.field "description", description
          json.field "images" do
            json.array do
              images.map do |image|
                json.object do
                  json.field "url", image
                end
              end
            end
          end
          json.field "videos" do
            json.array do
              videos.map do |video|
                json.object do
                  json.field "url", video.source.url
                  json.field "title", video.source.title
                  json.field "description", video.source.description
                  json.field "html", video.html
                  json.field "images" do
                    json.array do
                      video.source.images.map do |image|
                        json.object do
                          json.field "url", image
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
      string
    end
  end
end
