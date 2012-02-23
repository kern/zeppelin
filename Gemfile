source :rubygems
gemspec

group :development do
  gem 'rb-fsevent', :require => RUBY_PLATFORM.include?('darwin') && 'rb-fsevent'
  gem 'growl', :require => RUBY_PLATFORM.include?('darwin') && 'growl'
  gem 'guard'
  gem 'guard-bundler'
  gem 'guard-rspec'
end
