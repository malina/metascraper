# metascraper

Metascraper is a little lib for web scraping purposes.

You give it an URL, and it lets you easily get its title, images, description, videos.

## Installation


Add this to your application's `shard.yml`:

```yaml
dependencies:
  metascraper:
    github: malina/metascraper
```


## Usage


```crystal
require "metascraper"
```


Initialize a Metascraper instance for an URL, like this:

```crystal
page = Metascraper.new("https://github.com/malina/metascraper")

puts page.title
```

## Accessing scraped data

```crystal
page.url                 # URL of the page
page.images              # enumerable collection, with every img found on the page
page.title               # title of the page from the head section, as string
page.description         # returns the meta description, or the first long paragraph if no meta description is found
page.content             # primary readability page content
```

You can also access most of the scraped data as a hash:
```crystal
  page.to_hash
```

## Contributing

1. Fork it ( https://github.com/malina/metascraper/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [malina](https://github.com/malina) Alexandr Shumov - creator, maintainer
