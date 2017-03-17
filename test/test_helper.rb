require 'minitest/autorun'
require 'mocha'

path = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)

require 'diatex'
