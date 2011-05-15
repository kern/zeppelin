# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'zeppelin/version'

Gem::Specification.new do |s|
  s.name        = 'zeppelin'
  s.version     = Zeppelin::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Alexander Kern']
  s.email       = ['alex@kernul.com']
  s.homepage    = 'https://github.com/CapnKernul/zeppelin'
  s.summary     = %q{Urban Airship library for Ruby}
  s.description = %q{Ruby client for the Urban Airship RESTful API}
  
  s.rubyforge_project = 'zeppelin'
  
  s.add_dependency 'faraday'
  s.add_dependency 'yajl-ruby'
  
  s.add_development_dependency 'ansi'
  s.add_development_dependency 'minitest', '~> 2.0'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'test_declarative'
  
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
end