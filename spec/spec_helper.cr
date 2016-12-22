require "spec"
require "webmock"
require "../src/metascraper"

Spec.before_each &->WebMock.reset
