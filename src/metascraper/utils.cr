module Metascraper
  struct Utils
    def initialize(@source : String, @charset : String)
    end

    def encodeToUtf8 : String
      bytes = @source.encode(@charset)
      String.new(bytes)
    end
  end
end
