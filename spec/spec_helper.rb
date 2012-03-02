require 'rubygems'
require 'bundler/setup'

if RUBY_VERSION =~ /^1.9/ && RUBY_DESCRIPTION =~ /jruby|enterprise/i
  require 'simplecov'

  SimpleCov.start do
    add_filter '/spec/'
  end
end

require 'zeppelin'

RSpec.configure do |config|
end
