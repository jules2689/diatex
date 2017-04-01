require 'minitest/autorun'
require 'mocha'

path = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)

require 'webmock/minitest'

require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = "test/fixtures/vcr_cassettes"
  config.hook_into :webmock
end

require 'diatex'
