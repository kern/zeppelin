require 'test_helper'

class JsonParserMiddlewareTest < Zeppelin::TestCase
  def setup
    @json_body = "{\"foo\":\"bar\"}"
    @expected_parsed_body = { 'foo' => 'bar' }
  end

  test 'parses a standard JSON content type' do
    assert_equal @expected_parsed_body, process(@json_body, 'application/json').body
  end

  test 'parses vendor JSON content type' do
    assert_equal @expected_parsed_body, process(@json_body, 'application/vnd.urbanairship+json').body
  end

  test 'does not change nil body' do
    assert process(nil).body.nil?
  end

  test 'does not parse non-JSON content types' do
    assert_equal '<hello>world</hello>', process('<hello>world</hello>', 'text/xml').body
  end

  def process(body, content_type=nil, options={})
    env = { :body => body, :response_headers => Faraday::Utils::Headers.new }
    env[:response_headers]['content-type'] = content_type if content_type

    middleware = Zeppelin::JsonParserMiddleware.new(
      lambda { |env| Faraday::Response.new(env) }
    )

    middleware.call(env)
  end
end
