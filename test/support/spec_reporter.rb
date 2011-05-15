require 'minitest/unit'
require 'ansi'

# Code for this runner has been borrowed and modified from MiniTest, written by
# Ryan Davis of Seattle.rb. MiniTest is licensed under the MIT License, and can
# be found on GitHub at https://github.com/seattlerb/minitest.
# 
# This code is also heavily based upon these gists as well, which don't appear
# to have a license:
# * https://gist.github.com/356945
# * https://gist.github.com/960669
# 
# @abstract
# @todo Add documentation to everything.
module MiniTest
  class Reporter
    attr_accessor :runner
    
    def print(*args)
      runner.output.print(*args)
    end
    
    def puts(*args)
      runner.output.puts(*args)
    end
    
    def before_suites(suites); end
    def after_suites(suites); end
    def before_suite(suite); end
    def after_suite(suite); end
    def before_test(suite, test); end
    def pass(suite, test); end
    def skip(suite, test, e); end
    def failure(suite, test, e); end
    def error(suite, test, e); end
  end
end

module MiniTest
  class SpecReporter < Reporter
    include ANSI::Code
    
    TEST_PADDING = 2
    INFO_PADDING = 8
    MARK_SIZE    = 5
    
    def before_suites(suites)
      @suites_start_time = Time.now
      puts 'Started'
      puts
    end
    
    def after_suites(suites)
      total_time = Time.now - @suites_start_time
      
      puts('Finished in %.5fs' % total_time)
      print('%d tests, %d assertions, ' % [runner.test_count, runner.assertion_count])
      print(red { '%d failures, %d errors, ' } % [runner.failures, runner.errors])
      print(yellow { '%d skips' } % runner.skips)
      puts
    end
    
    def before_suite(suite)
      puts suite
    end
    
    def after_suite(suite)
      puts
    end
    
    def before_test(suite, test)
      @test_start_time = Time.now
    end
    
    def pass(suite, test)
      print(green { pad_mark('PASS') })
      print_test_with_time(test)
      puts
    end
    
    def skip(suite, test, e)
      print(yellow { pad_mark('SKIP') })
      print_test_with_time(test)
      puts
    end
    
    def failure(suite, test, e)
      print(red { pad_mark('FAIL') })
      print_test_with_time(test)
      puts
      print_info(e)
      puts
    end
    
    def error(suite, test, e)
      print(red { pad_mark('ERROR') })
      print_test_with_time(test)
      puts
      print_info(e)
      puts
    end
    
    private
    
    def print_test_with_time(test)
      total_time = Time.now - @test_start_time
      print(" #{test} (%.2fs)" % total_time)
    end
    
    def print_info(e)
      e.message.each_line { |line| puts pad(line, INFO_PADDING) }
      
      trace = MiniTest.filter_backtrace(e.backtrace)
      trace.each { |line| puts pad(line, INFO_PADDING) }
    end
    
    def pad(str, size)
      ' ' * size + str
    end
    
    def pad_mark(str)
      pad("%#{MARK_SIZE}s" % str, TEST_PADDING)
    end
  end
end

module MiniTest
  class RunnerWithReporter < Unit
    def initialize(new_reporter)
      super()
      @reporter = new_reporter
      @reporter.runner = self
    end
    
    def puke(suite, method, e)
      case e
      when MiniTest::Skip then
        @skips += 1
        [:skip, e]
      when MiniTest::Assertion then
        @failures += 1
        [:failure, e]
      else
        @errors += 1
        [:error, e]
      end
    end
    
    def _run_anything(type)
      @test_count = @assertion_count = 0
      suites = TestCase.send("#{type}_suites")
      return if suites.empty?
      
      @reporter.before_suites(suites)
      
      sync = output.respond_to?(:'sync=') # stupid emacs
      old_sync, output.sync = output.sync, true if sync
      _run_suites(suites, type)
      output.sync = old_sync if sync
      
      @reporter.after_suites(suites)
    end
    
    def _run_suites(suites, type)
      suites.map { |suite| _run_suite(suite, type) }
    end
    
    def _run_suite(suite, type)
      run_suite_header(suite, type)
      
      filter = options[:filter] || '/./'
      filter = Regexp.new($1) if filter =~ /\/(.*)\//
      
      tests = suite.send("#{type}_methods").grep(filter)
      
      unless tests.empty?
        @reporter.before_suite(suite)
        run_suite_tests(suite, tests)
        @reporter.after_suite(suite)
      end
    end
    
    private
    
    def run_suite_header(suite, type)
      header_method = "#{type}_suite_header"
      send(header_method, suite) if respond_to?(header_method)
    end
    
    def run_suite_tests(suite, tests)
      suite.startup if suite.respond_to?(:startup)
      
      tests.each do |test|
        @reporter.before_test(suite, test)
        response, e = run_suite_test(suite, test)
        
        case response
        when :pass then @reporter.pass(suite, test)
        when :skip then @reporter.skip(suite, test, e)
        when :failure then @reporter.failure(suite, test, e)
        else @reporter.error(suite, test, e)
        end
      end
    ensure
      suite.shutdown if suite.respond_to?(:shutdown)
    end
    
    def run_suite_test(suite, test)
      suite_instance = suite.new(test)
      suite_instance._assertions = 0
      
      result = suite_instance.run(self)
      
      @test_count += 1
      @assertion_count += suite_instance._assertions
      
      result == '.' ? :pass : result
    end
  end
end

MiniTest::Unit.runner = MiniTest::RunnerWithReporter.new(MiniTest::SpecReporter.new)