require "./spec_helper"

describe Metascraper do
  url = "https://example.com"

  it "get document title" do
    WebMock.stub(:get, url).to_return(body: %(
      <html>
        <head>
          <title>Title</title>
        </head>
      </html>
    ))

    page = Metascraper.new(url)

    page.to_hash["title"].should eq("Title")
  end

  it "get meta og:title" do
    url = "https://example.com"
    WebMock.stub(:get, url).to_return(body: %(
      <html>
        <head>
          <meta property="og:title" content="Title">
        </head>
      </html>
    ))

    page = Metascraper.new(url)

    page.to_hash["title"].should eq("Title")
  end

  it "get meta description" do
    url = "https://example.com"
    WebMock.stub(:get, url).to_return(body: %(
      <html>
        <head>
        <meta name="description" content="Description">
        </head>
      </html>
    ))

    page = Metascraper.new(url)

    page.to_hash["description"].should eq("Description")
  end

  it "get description from body" do
    description = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book."
    url = "https://example.com"
    WebMock.stub(:get, url).to_return(body: %(
      <html>
        <body>
          <p>Text</p>
          <div>#{description}</div>
        </body>
      </html>
    ))

    page = Metascraper.new(url)

    page.to_hash["description"].should eq(description)
  end

  it "get images with min width" do
    url = "https://example.com"
    image_url = "https://example.com/image.jpg"
    image_url_with_width = "https://example.com/image_with_min_width.jpg"
    WebMock.stub(:get, url).to_return(body: %(
      <html>
        <body>
          <img src="#{image_url}">
          <img src="#{image_url_with_width}" width=600>
        </body>
      </html>
    ))

    page = Metascraper.new(url)

    page.to_hash["images"].should eq([image_url_with_width])
  end

  it "get images" do
    url = "https://example.com"
    image_url = "https://example.com/image.jpg"
    image_url_with_width = "https://example.com/image_with_min_width.jpg"
    WebMock.stub(:get, url).to_return(body: %(
      <html>
        <body>
          <img src="#{image_url}">
          <img src="#{image_url_with_width}" width="600">
        </body>
      </html>
    ))

    page = Metascraper.new(url, {all_image: true})

    page.to_hash["images"].should eq([image_url, image_url_with_width])
  end

  it "get readability content" do
    description = "<p>Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.</p>"
    url = "https://example.com"
    WebMock.stub(:get, url).to_return(body: %(
      <html>
        <body>
          <main class="main">
            <p>Text</p>
            <article>
              #{description}
            </article>
          </main>
        </body>
      </html>
    ))

    page = Metascraper.new(url)

    puts page.content

    page.content.should eq(description)
  end
end
