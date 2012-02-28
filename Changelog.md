# dev

## Enhancements

* Can load APID collection
* Can load device token collection

## Changes

* Removed usage of Bundler gem tasks. It's easier to do this by hand.

# 0.6.0

## Enhancements

* [MultiJson](https://github.com/intridea/multi_json) used to handle JSON
  encoding/decoding. Using the JSON engine of your choice is as simple
  as: `MultiJson.engine = :your_choice`

## Breaking Changes

* Instead of having an invalid request return false, exceptions will be raised
  with messages containing details about the fail. This allows for
  better error handling. Should the desired resource not be found,
  `Zeppelin::ResourceNotFound` will be raised, for other errors,
  `Zeppelin::ClientError` will be raised. Successful responses will still
  return `true`.

## Changes

* Now using RSpec as the test harness
* CI covers Ruby 1.9.3
* [James Herdman](https://github.com/jherdman) added as a contributor

# 0.5.0

## Changes

* Refactored handling of responses
