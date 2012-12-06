# zeppelin - Urban Airship library for Ruby [![StillMaintained Status](http://stillmaintained.com/CapnKernul/zeppelin.png)](http://stillmaintained.com/CapnKernul/zeppelin) [![Build Status](https://travis-ci.org/CapnKernul/zeppelin.png)](https://travis-ci.org/CapnKernul/zeppelin)

Ruby client for the [Urban Airship](http://urbanairship.com) Push Notification
API.

## Installation ##

Without bundler:

    gem install zeppelin

With bundler:

    gem 'zeppelin'

## Usage ##

    # First, create a client.
    client = Zeppelin.new('your app key', 'your app master secret')
    
    # You can then use the client to push messages to Urban Airship. The options
    # for push are converted to JSON and sent as the payload.
    client.push(:device_tokens => ['devtoken'], :aps => { :badge => 10 })

Check out the docs for more ways of querying the API.

## Note on Patches/Pull Requests ##

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version unintentionally.
* Commit, but do not mess with the `Rakefile`. If you want to have your own version, that is fine but bump the version in a commit by itself in another branch so I can ignore it when I pull.
* Send me a pull request. Bonus points for git flow feature branches.

## Resources ##

* [GitHub Repository](https://github.com/CapnKernul/zeppelin)
* [Documentation](http://rubydoc.info/github/CapnKernul/zeppelin)
* [Issues](https://github.com/CapnKernul/zeppelin/issues)

## License ##

Zeppelin is licensed under the MIT License. See `LICENSE` for details.
