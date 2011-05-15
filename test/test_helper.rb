require 'bundler/setup'
require 'minitest/autorun'
require 'mocha'
require 'test_declarative'
require 'zeppelin'

Dir[File.expand_path('../support/**/*.rb', __FILE__)].each { |f| require f }

class Zeppelin::TestCase < MiniTest::Unit::TestCase; end