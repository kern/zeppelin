require 'test_helper'

class ZeppelinTest < Zeppelin::TestCase
  def setup
    @client = Zeppelin.new('app key', 'app master secret')
    @device_token = '1234567890ABCDEF1234567890ABCDEF1234567890ABCDEF1234567890ABCDEF'
  end
  
  test '#connection' do
    assert_instance_of Faraday::Connection, @client.connection
    assert_equal 'https', @client.connection.scheme
    assert_equal 'go.urbanairship.com', @client.connection.host
    assert_includes @client.connection.builder.handlers, Faraday::Adapter::NetHttp
    assert_includes @client.connection.builder.handlers, Faraday::Request::JSON
    assert_equal 'Basic YXBwIGtleTphcHAgbWFzdGVyIHNlY3JldA==', @client.connection.headers['Authorization']
  end
  
  test '#register_device_token without a payload' do
    stub_requests @client.connection do |stub|
      stub.put("/api/device_tokens/#{@device_token}") do [201, {}, '']
      end
    end
    
    response = @client.register_device_token(@device_token)
    assert response
  end
  
  test '#register_device_token an already registered device token' do
    stub_requests @client.connection do |stub|
      stub.put("/api/device_tokens/#{@device_token}") do
        [200, {}, '']
      end
    end
    
    response = @client.register_device_token(@device_token)
    assert response
  end
  
  test '#register_device_token with payload' do
    payload = { :alias => 'CapnKernul' }
    
    stub_requests @client.connection do |stub|
      stub.put("/api/device_tokens/#{@device_token}", Yajl::Encoder.encode(payload)) do
        [200, {}, '']
      end
    end
    
    response = @client.register_device_token(@device_token, payload)
    assert response
  end
  
  test '#register_device_token with an error' do
    stub_requests @client.connection do |stub|
      stub.put("/api/device_tokens/#{@device_token}", nil) do
        [500, {}, '']
      end
    end
    
    response = @client.register_device_token(@device_token)
    refute response
  end
  
  test '#device_token with valid device token' do
    response_body = { 'foo' => 'bar' }
    stub_requests @client.connection do |stub|
      stub.get("/api/device_tokens/#{@device_token}") do
        [200, {}, Yajl::Encoder.encode(response_body)]
      end
    end
    
    response = @client.device_token(@device_token)
    assert_equal response_body, response
  end
  
  test '#device_token with an unknown device token' do
    stub_requests @client.connection do |stub|
      stub.get("/api/device_tokens/#{@device_token}") do
        [404, {}, '']
      end
    end
    
    response = @client.device_token(@device_token)
    assert_nil response
  end
  
  test '#delete_device_token with a valid device token' do
    stub_requests @client.connection do |stub|
      stub.delete("/api/device_tokens/#{@device_token}") do
        [204, {}, '']
      end
    end
    
    response = @client.delete_device_token(@device_token)
    assert response
  end
  
  test '#delete_device_token with an unknown device token' do
    stub_requests @client.connection do |stub|
      stub.delete("/api/device_tokens/#{@device_token}") do
        [404, {}, '']
      end
    end
    
    response = @client.delete_device_token(@device_token)
    refute response
  end
  
  test '#register_apid without a payload' do
    stub_requests @client.connection do |stub|
      stub.put("/api/apids/#{@apid}") do [201, {}, '']
      end
    end
    
    response = @client.register_apid(@apid)
    assert response
  end
  
  test '#register_apid an already registered APID' do
    stub_requests @client.connection do |stub|
      stub.put("/api/apids/#{@apid}") do
        [200, {}, '']
      end
    end
    
    response = @client.register_apid(@apid)
    assert response
  end
  
  test '#register_apid with payload' do
    payload = { :alias => 'CapnKernul' }
    
    stub_requests @client.connection do |stub|
      stub.put("/api/apids/#{@apid}", Yajl::Encoder.encode(payload)) do
        [200, {}, '']
      end
    end
    
    response = @client.register_apid(@apid, payload)
    assert response
  end
  
  test '#register_apid with an error' do
    stub_requests @client.connection do |stub|
      stub.put("/api/apids/#{@apid}", nil) do
        [500, {}, '']
      end
    end
    
    response = @client.register_apid(@apid)
    refute response
  end
  
  test '#apid' do
    response_body = { 'foo' => 'bar' }
    stub_requests @client.connection do |stub|
      stub.get("/api/apids/#{@apid}") do
        [200, {}, Yajl::Encoder.encode(response_body)]
      end
    end
    
    response = @client.apid(@apid)
    assert_equal response_body, response
  end
  
  test '#delete_apid with a valid APID' do
    stub_requests @client.connection do |stub|
      stub.delete("/api/apids/#{@apid}") do
        [204, {}, '']
      end
    end
    
    response = @client.delete_apid(@apid)
    assert response
  end
  
  test '#delete_apid with an unknown APID' do
    stub_requests @client.connection do |stub|
      stub.delete("/api/apids/#{@apid}") do
        [404, {}, '']
      end
    end
    
    response = @client.delete_apid(@apid)
    refute response
  end
  
  test '#push with a valid payload' do
    payload = {
      :device_tokens => [@device_token],
      :aps => { :alert => 'Hello from Urban Airship!' }
    }
    
    stub_requests @client.connection do |stub|
      stub.post('/api/push/', Yajl::Encoder.encode(payload)) do
        [200, {}, '']
      end
    end
    
    response = @client.push(payload)
    assert response
  end
  
  # Although the Urban Airship documentation states that a 400 Status Code
  # will be sent when there's an invalid payload, it doesn't state what
  # constitutes an invalid payload. Hence, I'm just mocking out the request so
  # that it returns a 400.
  test '#push with an invalid payload' do
    stub_requests @client.connection do |stub|
      stub.post('/api/push/', '{}') do
        [400, {}, '']
      end
    end
    
    response = @client.push({})
    refute response
  end
  
  test '#batch_push with a valid payload' do
    message1 = {
      :device_tokens => [@device_token],
      :aps => { :alert => 'Hello from Urban Airship!' }
    }
    
    message2 = {
      :device_tokens => [],
      :aps => { :alert => 'Yet another hello from Urban Airship!' }
    }
    
    payload = [message1, message2]
    
    stub_requests @client.connection do |stub|
      stub.post('/api/push/batch/', Yajl::Encoder.encode(payload)) do
        [200, {}, '']
      end
    end
    
    response = @client.batch_push(message1, message2)
    assert response
  end
  
  # See the note above for why this test exists.
  test '#batch_push with an invalid payload' do
    stub_requests @client.connection do |stub|
      stub.post('/api/push/batch/', '[{},{}]') do
        [400, {}, '']
      end
    end
    
    response = @client.batch_push({}, {})
    refute response
  end
  
  test '#broadcast with a valid payload' do
    payload = {
      :aps => { :alert => 'Hello from Urban Airship!' }
    }
    
    stub_requests @client.connection do |stub|
      stub.post('/api/push/broadcast/', Yajl::Encoder.encode(payload)) do
        [200, {}, '']
      end
    end
    
    response = @client.broadcast(payload)
    assert response
  end
  
  # See the note above for why this test exists.
  test '#broadcast with an invalid payload' do
    stub_requests @client.connection do |stub|
      stub.post('/api/push/broadcast/', '{}') do
        [400, {}, '']
      end
    end
    
    response = @client.broadcast({})
    refute response
  end
  
  test '#feedback with a valid since' do
    response_body = { 'foo' => 'bar' }
    since = Time.at(0)
    
    stub_requests @client.connection do |stub|
      stub.get('/api/device_tokens/feedback/?since=1970-01-01T00%3A00%3A00Z') do
        [200, {}, Yajl::Encoder.encode(response_body)]
      end
    end
    
    response = @client.feedback(since)
    assert_equal response_body, response
  end
  
  test '#feedback with an error' do
    since = Time.at(0)
    
    stub_requests @client.connection do |stub|
      stub.get('/api/device_tokens/feedback/?since=1970-01-01T00%3A00%3A00Z') do
        [400, {}, '']
      end
    end
    
    response = @client.feedback(since)
    assert_nil response
  end

  test '#add_tag' do
    tag_name = 'chunky.bacon'

    stub_requests @client.connection do |stub|
      stub.put("/api/tags/#{tag_name}") do
        [201, {}, '']
      end
    end

    response = @client.add_tag(tag_name)
    assert response
  end

  test '#remove_tag with an existing tag' do
    tag_name = 'cats.pajamas'

    stub_requests @client.connection do |stub|
      stub.delete("/api/tags/#{tag_name}") do
        [204, {}, '']
      end
    end

    response = @client.remove_tag(tag_name)
    assert response
  end

  test '#remove_tag with non-existant tag' do
    tag_name = 'cats.pajamas'

    stub_requests @client.connection do |stub|
      stub.delete("/api/tags/#{tag_name}") do
        [404, {}, 'Not Found']
      end
    end

    response = @client.remove_tag(tag_name)
    refute response
  end

  test '#add_tag_to_device' do
    tag_name = 'radio.head'
    device_token = 'CAFEBABE'

    stub_requests @client.connection do |stub|
      stub.put("/api/device_tokens/#{device_token}/tags/#{tag_name}") do
        [201, {}, 'Created']
      end
    end

    response = @client.add_tag_to_device(device_token, tag_name)
    assert response
  end

  test '#remove_tag_from_device successfully' do
    tag_name = 'martin.fowler'
    device_token = 'DEADBEEF'

    stub_requests @client.connection do |stub|
      stub.delete("/api/device_tokens/#{device_token}/tags/#{tag_name}") do
        [204, {}, 'No Content']
      end
    end

    response = @client.remove_tag_from_device(device_token, tag_name)
    assert response
  end

  test '#remove_tag_from_device unsuccessfully' do
    tag_name = 'martin.fowler'
    device_token = 'DEADBEEF'

    stub_requests @client.connection do |stub|
      stub.delete("/api/device_tokens/#{device_token}/tags/#{tag_name}") do
        [404, {}, 'Not Found']
      end
    end

    response = @client.remove_tag_from_device(device_token, tag_name)
    refute response
  end
  
  def stub_requests(connection, &block)
    connection.builder.handlers.delete(Faraday::Adapter::NetHttp)
    connection.adapter(:test, &block)
  end
end
