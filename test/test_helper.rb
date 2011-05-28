require 'bundler/setup'
require 'minitest/autorun'
require 'journo'
require 'mocha'
require 'test_declarative'
require 'zeppelin'

Dir[File.expand_path('../support/**/*.rb', __FILE__)].each { |f| require f }

class Zeppelin::TestCase < MiniTest::Unit::TestCase; end

MiniTest::Unit.runner = Journo::SuiteRunner.new
MiniTest::Unit.runner.reporters << Journo::Reporters::ProgressReporter.new