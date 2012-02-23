require 'spec_helper'

describe Zeppelin::JsonParserMiddleware do
  let(:json_body) { "{\"foo\":\"bar\"}" }

  let(:expected_parsed_body) { { 'foo' => 'bar' } }

  it 'parses a standard JSON content type' do
    process(json_body, 'application/json').body.should eq(expected_parsed_body)
  end

  it 'parses vendor JSON content type' do
    process(json_body, 'application/vnd.urbanairship+json').body.should eq(expected_parsed_body)
  end

  it 'does not change nil body' do
    process(nil).body.should be_nil
  end

  it 'does not parse non-JSON content types' do
    process('<hello>world</hello>', 'text/xml').body.should eq('<hello>world</hello>')
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
