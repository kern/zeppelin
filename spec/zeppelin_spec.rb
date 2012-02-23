require 'spec_helper'

describe Zeppelin do
  let(:device_token) { '1234567890ABCDEF1234567890ABCDEF1234567890ABCDEF1234567890ABCDEF' }

  let(:app_key) { 'app key' }

  let(:master_secret) { 'app master secret' }

  let(:options) { { :ssl => { :ca_path => '/dev/null' } } }

  subject { Zeppelin.new(app_key, master_secret, options) }

  describe '.new' do
    its(:application_key) { should eq(app_key) }

    its(:application_master_secret) { should eq(master_secret) }

    its(:options) { should eq(options) }
  end

  describe '#connection' do
    it { subject.connection.should be_a(Faraday::Connection) }

    it { subject.connection.scheme.should eq('https') }

    it { subject.connection.host.should eq('go.urbanairship.com') }

    it { subject.connection.builder.handlers.should include(Faraday::Adapter::NetHttp) }

    it { subject.connection.builder.handlers.should include(Faraday::Request::JSON) }

    it { subject.connection.builder.handlers.should include(Zeppelin::Middleware::JsonParser) }

    it { subject.connection.headers['Authorization'].should eq('Basic YXBwIGtleTphcHAgbWFzdGVyIHNlY3JldA==') }
  end

  describe '#register_device_token' do
    let(:payload) { { :alias => 'CapnKernul' } }

    it 'registers a device with the service' do
      stub_requests do |stub|
        stub.put("/api/device_tokens/#{device_token}") do |stub|
          [201, {}, '']
        end
      end
    
      subject.register_device_token(device_token).should be_true
    end

    it 'accepts a payload' do
      stub_requests do |stub|
        stub.put("/api/device_tokens/#{device_token}", MultiJson.encode(payload)) do
          [200, {}, '']
        end
      end
    
      subject.register_device_token(device_token, payload).should be_true
    end

    it 'responds with false when an error occurs' do
      stub_requests do |stub|
        stub.put("/api/device_tokens/#{device_token}", nil) do
          [500, {}, '']
        end
      end
    
      subject.register_device_token(device_token).should be_false
    end
  end

  describe '#device_token' do
   let(:response_body) { { 'foo' => 'bar' } }

    it 'gets information about a device' do
      stub_requests do |stub|
       stub.get("/api/device_tokens/#{device_token}") do
         [200, { 'Content-Type' => 'application/json' }, MultiJson.encode(response_body)]
       end
      end

      subject.device_token(device_token).should eq(response_body)
    end

    it 'is nil when the request fails' do
      stub_requests do |stub|
       stub.get("/api/device_tokens/#{device_token}") do
         [404, {}, '']
       end
      end

      subject.device_token(device_token).should be_nil
    end
  end

  describe '#delete_device_token' do
    it 'is true when successful' do
      stub_requests do |stub|
       stub.delete("/api/device_tokens/#{device_token}") do
         [204, {}, '']
       end
      end

      subject.delete_device_token(device_token).should be_true
    end

    it 'is false when the request fails' do
      stub_requests do |stub|
       stub.delete("/api/device_tokens/#{device_token}") do
         [404, {}, '']
       end
      end

      subject.delete_device_token(device_token).should be_false
    end
  end

  describe '#register_apid' do
    let(:payload) { { :alias => 'CapnKernul' } }

    it 'registers a device with the service' do
      stub_requests do |stub|
        stub.put("/api/apids/#{device_token}") do |stub|
          [201, {}, '']
        end
      end
    
      subject.register_apid(device_token).should be_true
    end

    it 'accepts a payload' do
      stub_requests do |stub|
        stub.put("/api/apids/#{device_token}", MultiJson.encode(payload)) do
          [200, {}, '']
        end
      end
    
      subject.register_apid(device_token, payload).should be_true
    end

    it 'responds with false when an error occurs' do
      stub_requests do |stub|
        stub.put("/api/apids/#{device_token}", nil) do
          [500, {}, '']
        end
      end
    
      subject.register_apid(device_token).should be_false
    end
  end

  describe '#apid' do
    let(:response_body) { { 'foo' => 'bar' } }

    it 'responds with information about a device when request is successful' do
      stub_requests do |stub|
        stub.get("/api/apids/#{device_token}") do
          [200, { 'Content-Type' => 'application/json' }, MultiJson.encode(response_body)]
        end
      end

      subject.apid(device_token).should eq(response_body)
    end

    it 'is nil when the request fails' do
      stub_requests do |stub|
        stub.get("/api/apids/#{device_token}") do
          [404, {}, '']
        end
      end

      subject.apid(device_token).should be_nil
    end
  end

  describe '#delete_apid' do
    it 'responds with true when request successful' do
      stub_requests do |stub|
          stub.delete("/api/apids/#{device_token}") do
          [204, {}, '']
        end
      end

      subject.delete_apid(device_token).should be_true
    end

    it 'responds with false when request fails' do
      stub_requests do |stub|
        stub.delete("/api/apids/#{device_token}") do
          [404, {}, '']
        end
      end
   
      subject.delete_apid(device_token).should be_false
    end
  end

  describe '#push' do
    let(:payload) { { :device_tokens => [device_token], :aps => { :alert => 'Hello from Urban Airship!' } } }

    it 'is true when the request is successful' do
      stub_requests do |stub|
        stub.post('/api/push/', MultiJson.encode(payload)) do
          [200, {}, '']
        end
      end

      subject.push(payload).should be_true
    end

    it 'is false when the request fails' do
      stub_requests do |stub|
        stub.post('/api/push/', '{}') do
          [400, {}, '']
        end
      end

      subject.push({}).should be_false
    end
  end

  describe '#batch_push' do
    let(:message1) {
      {
        :device_tokens => [@device_token],
        :aps => { :alert => 'Hello from Urban Airship!' }
      }
    }

    let(:message2) {
      {
        :device_tokens => [],
        :aps => { :alert => 'Yet another hello from Urban Airship!' }
      }
    }

    let(:payload) { [message1, message2] }

    it 'is true when the request was successful' do
      stub_requests do |stub|
        stub.post('/api/push/batch/', MultiJson.encode(payload)) do
         [200, {}, '']
        end
      end

      subject.batch_push(message1, message2).should be_true
    end

    it 'is false when the request fails' do
      stub_requests do |stub|
        stub.post('/api/push/batch/', '[{},{}]') do
          [400, {}, '']
        end
      end
     
      subject.batch_push({}, {}).should be_false
    end
  end

  describe '#broadcast' do
    let(:payload) {  { :aps => { :alert => 'Hello from Urban Airship!' } } }

    it 'is true when the request is successful' do
      stub_requests do |stub|
        stub.post('/api/push/broadcast/', MultiJson.encode(payload)) do
          [200, {}, '']
        end
      end

      subject.broadcast(payload).should be_true
    end

    it 'is false when the request fails' do
      stub_requests do |stub|
        stub.post('/api/push/broadcast/', '{}') do
          [400, {}, '']
        end
      end
  
      subject.broadcast({}).should be_false
    end
  end

  describe '#feedback' do
    let(:response_body) { { 'foo' => 'bar' } }

    let(:since) { Time.at(0) }

    it 'is the response body for a successful request' do
      stub_requests do |stub|
        stub.get('/api/device_tokens/feedback/?since=1970-01-01T00%3A00%3A00Z') do
          [200, { 'Content-Type' => 'application/json' }, MultiJson.encode(response_body)]
        end
      end
      
      subject.feedback(since)
    end

    it 'is nil when the request fails' do
      stub_requests do |stub|
        stub.get('/api/device_tokens/feedback/?since=1970-01-01T00%3A00%3A00Z') do
          [400, {}, '']
        end
      end

      subject.feedback(since).should be_false
    end
  end

  describe '#modify_device_token_on_tag' do
    let(:tag_name) { 'jimmy.page' }

    let(:device_token) { 'CAFEBABE' }
  
    it 'requets to modify device tokens on a tag' do
      stub_requests do |stub|
        stub.post("/api/tags/#{tag_name}") do
          [200, {}, 'OK']
        end
      end
    
      subject.modify_device_tokens_on_tag(tag_name, { 'device_tokens' => { 'add' => [device_token] } }).should be
    end
  end

  describe '#add_tag' do
    let(:tag_name) { 'chunky.bacon' }

    it 'is true when the request is successful' do
      stub_requests do |stub|
        stub.put("/api/tags/#{tag_name}") do
          [201, {}, '']
        end
      end

      subject.add_tag(tag_name).should be_true
    end

    it 'is false when the request fails' do
      stub_requests do |stub|
        stub.put("/api/tags/#{tag_name}") do
          [404, {}, '']
        end
      end

      subject.add_tag(tag_name).should be_false
    end
  end

  describe '#remove_tag' do
    let(:tag_name) { 'cats.pajamas' }

    it 'is true when the request is successful' do
      stub_requests do |stub|
        stub.delete("/api/tags/#{tag_name}") do
          [204, {}, '']
        end
      end

      subject.remove_tag(tag_name).should be_true
    end

    it 'is false when the request fails' do
      stub_requests do |stub|
        stub.delete("/api/tags/#{tag_name}") do
          [404, {}, '']
        end
      end

      subject.remove_tag(tag_name).should be_false
    end
  end

  describe '#device_tags' do
    let(:response_body) { { 'tags' => ['tag1', 'some_tag'] } }

    it 'is the collection of tags on a device when request is successful' do
      stub_requests do |stub|
        stub.get("/api/device_tokens/#{device_token}/tags/") do
          [200, { 'Content-Type' => 'application/json' }, MultiJson.encode(response_body)]
        end
      end

      subject.device_tags(device_token).should eq(response_body)
    end

    it 'is nil when the request fails' do
      stub_requests do |stub|
        stub.get("/api/device_tokens/#{device_token}/tags/") do
          [404, {}, 'Not Found']
        end
      end

      subject.device_tags(device_token).should be_nil
    end
  end

  describe '#add_tag_to_device' do
    let(:tag_name) { 'radio.head' }

    it 'is true when the request is successful' do
      stub_requests do |stub|
        stub.put("/api/device_tokens/#{device_token}/tags/#{tag_name}") do
          [201, {}, 'Created']
        end
      end

      subject.add_tag_to_device(device_token, tag_name).should be_true
    end

    it 'is false when the request fails' do
      stub_requests do |stub|
        stub.put("/api/device_tokens/#{device_token}/tags/#{tag_name}") do
          [400, {}, '']
        end
      end

      subject.add_tag_to_device(device_token, tag_name).should be_false
    end
  end

  describe '#remove_tag_from_device' do
    let(:tag_name) { 'martin.fowler' }

    it 'is true when the request is successful' do
      stub_requests do |stub|
        stub.delete("/api/device_tokens/#{device_token}/tags/#{tag_name}") do
          [204, {}, 'No Content']
        end
      end

      subject.remove_tag_from_device(device_token, tag_name).should be_true
    end

    it 'is false when the request fails' do
      stub_requests do |stub|
        stub.delete("/api/device_tokens/#{device_token}/tags/#{tag_name}") do
          [400, {}, '']
        end
      end

      subject.remove_tag_from_device(device_token, tag_name).should be_false
    end
  end
  
  def stub_requests(&block)
    subject.connection.builder.handlers.delete(Faraday::Adapter::NetHttp)
    subject.connection.adapter(:test, &block)
  end
end
