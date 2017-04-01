require 'minitest/autorun'
require 'mocha'
require 'byebug'

path = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)

require 'webmock/minitest'

require 'vcr'

VCR.configure do |config|
  config.hook_into :webmock
  config.cassette_library_dir = "test/fixtures/vcr_cassettes"
end

require 'diatex'
