require 'rubygems'
require 'bundler/setup'

begin
  require 'simplecov'

  SimpleCov.start do
    add_filter '/spec/'
  end
rescue => ex
  puts 'Running without test coverage checks (requires MRI 1.9)'
end

require 'zeppelin'

RSpec.configure do |config|
end
