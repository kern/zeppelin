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

    it { subject.connection.builder.handlers.should include(Zeppelin::Middleware::ResponseRaiseError) }

    it { subject.connection.headers['Authorization'].should eq('Basic YXBwIGtleTphcHAgbWFzdGVyIHNlY3JldA==') }
  end

  describe '#register_device_token' do
    let(:uri) { "/api/device_tokens/#{device_token}" }

    let(:payload) { { :alias => 'CapnKernul' } }

    it 'registers a device with the service' do
      stub_requests do |stub|
        stub.put(uri) { [201, {}, ''] }
      end

      subject.register_device_token(device_token).should be_true
    end

    it 'accepts a payload' do
      stub_requests do |stub|
        stub.put(uri) { [201, {}, ''] }
      end

      subject.register_device_token(device_token, payload)
    end

    it 'responds with false when an error occurs' do
      stub_requests do |stub|
        stub.put(uri) { [500, {}, ''] }
      end

      expect {
        subject.register_device_token(device_token)
      }.to raise_error(Zeppelin::ClientError)
    end
  end

  describe '#device_token' do
    let(:uri) { "/api/device_tokens/#{device_token}" }

    let(:response_body) { { 'foo' => 'bar' } }

    it 'gets information about a device' do
      stub_requests do |stub|
        stub.get(uri) { [200, { 'Content-Type' => 'application/json' }, MultiJson.encode(response_body)] }
      end

      subject.device_token(device_token).should eq(response_body)
    end

    it 'raises an error when the request fails' do
      stub_requests do |stub|
        stub.get(uri) { [404, {}, ''] }
      end

      expect {
        subject.device_token(device_token)
      }.to raise_error(Zeppelin::ResourceNotFound)
    end
  end

  describe '#delete_device_token' do
    let(:uri) { "/api/device_tokens/#{device_token}" }

    it 'is true when successful' do
      stub_requests do |stub|
        stub.delete(uri) { [204, {}, ''] }
      end

      subject.delete_device_token(device_token).should be_true
    end

    it 'raises an error when the request fails' do
      stub_requests do |stub|
        stub.delete(uri) { [404, {}, ''] }
      end

      expect {
        subject.delete_device_token(device_token)
      }.to raise_error(Zeppelin::ResourceNotFound)
    end
  end

  describe '#device_tokens' do
    let(:results_without_next_page) {
      {
        'device_tokens_count' => 1,
        'device_tokens' => [
          {
            'device_token' => 'example device token',
            'active' => true,
            'alias' => nil,
            'last_registration' => Time.mktime(2009, 6, 26, 19, 4, 43).to_s
          }
        ],
        'current_page' => 1,
        'num_pages' => 1,
        'active_device_tokens' => 1
      }
    }

    let(:results_with_next_page) {
      results_without_next_page.merge('next_page' => 'https://go.urbanairship.com/api/device_tokens/?page=2&limit=5000')
    }

    it 'requests a page of device tokens' do
      stub_requests do |stub|
        stub.get('/api/device_tokens/?page=') { [200, { 'Content-Type' => 'application/json' }, MultiJson.encode(results_without_next_page)] }
      end

      subject.device_tokens.should eq(results_without_next_page)
    end

    it 'includes the page number of the next page' do
      stub_requests do |stub|
        stub.get('/api/device_tokens/?page=') { [200, { 'Content-Type' => 'application/json' }, MultiJson.encode(results_with_next_page)] }
      end

      subject.device_tokens['next_page'].should eq(2)
    end

    it 'does not include the page number if there are no additional pages' do
      stub_requests do |stub|
        stub.get('/api/device_tokens/?page=') { [200, { 'Content-Type' => 'application/json' }, MultiJson.encode(results_without_next_page)] }
      end

      subject.device_tokens.should_not have_key('next_page')
    end

    it 'requests a specified page of device_tokens' do
      stub_requests do |stub|
        stub.get('/api/device_tokens/?page=4') { [200, { 'Content-Type' => 'application/json' }, MultiJson.encode(results_without_next_page)] }
      end

      subject.device_tokens(4)
    end

    it 'raises an error when the request fails' do
      stub_requests do |stub|
        stub.get('/api/device_tokens/?page=') { [500, {}, ''] }
      end

      expect {
        subject.device_tokens
      }.to raise_error(Zeppelin::ClientError)
    end
  end

  describe '#register_apid' do
    let(:uri) { "/api/apids/#{device_token}" }

    let(:payload) { { :alias => 'CapnKernul' } }

    it 'registers a device with the service' do
      stub_requests do |stub|
        stub.put(uri) { [201, {}, ''] }
      end

      subject.register_apid(device_token).should be_true
    end

    it 'accepts a payload' do
      stub_requests do |stub|
        stub.put(uri, MultiJson.encode(payload)) { [200, {}, ''] }
      end

      subject.register_apid(device_token, payload).should be_true
    end

    it 'raises an error when the request fails' do
      stub_requests do |stub|
        stub.put(uri) { [500, {}, ''] }
      end

      expect {
        subject.register_apid(device_token)
      }.to raise_error(Zeppelin::ClientError)
    end
  end

  describe '#apid' do
    let(:uri) { "/api/apids/#{device_token}" }

    let(:response_body) { { 'foo' => 'bar' } }

    it 'responds with information about a device when request is successful' do
      stub_requests do |stub|
        stub.get(uri) { [200, { 'Content-Type' => 'application/json' }, MultiJson.encode(response_body)] }
      end

      subject.apid(device_token).should eq(response_body)
    end

    it 'raises an error when the request fails' do
      stub_requests do |stub|
        stub.get("/api/apids/#{device_token}") { [404, {}, ''] }
      end

      expect {
        subject.apid(device_token)
      }.to raise_error(Zeppelin::ResourceNotFound)
    end
  end

  describe '#delete_apid' do
    let(:uri) { "/api/apids/#{device_token}" }

    it 'responds with true when request successful' do
      stub_requests do |stub|
          stub.delete(uri) { [204, {}, ''] }
      end

      subject.delete_apid(device_token).should be_true
    end

    it 'raises an error when the request fails' do
      stub_requests do |stub|
        stub.delete(uri) { [404, {}, ''] }
      end

      expect {
        subject.delete_apid(device_token)
      }.to raise_error(Zeppelin::ResourceNotFound)
    end
  end

  describe '#apids' do
    let(:results_without_next_page) {
      {
        'apids' => [
          {
            'apid' => 'example apid',
            'active' => true,
            'alias' => '',
            'tags' => []
          }
        ]
      }
    }

    let(:results_with_next_page) {
      results_without_next_page.merge('next_page' => 'https://go.urbanairship.com/api/apids/?start=2&limit=5000')
    }

    it 'requests a page of APIDs' do
      stub_requests do |stub|
        stub.get('/api/apids/?page=') { [200, { 'Content-Type' => 'application/json' }, MultiJson.encode(results_without_next_page)] }
      end

      subject.apids.should eq(results_without_next_page)
    end

    it 'includes the page number of the next page' do
      stub_requests do |stub|
        stub.get('/api/apids/?page=') { [200, { 'Content-Type' => 'application/json' }, MultiJson.encode(results_with_next_page)] }
      end

      subject.apids['next_page'].should eq(2)
    end

    it 'does not include the page number if there are no additional pages' do
      stub_requests do |stub|
        stub.get('/api/apids/?page=') { [200, { 'Content-Type' => 'application/json' }, MultiJson.encode(results_without_next_page)] }
      end

      subject.apids.should_not have_key('next_page')
    end

    it 'requests a specified page of APIDs' do
      stub_requests do |stub|
        stub.get('/api/apids/?page=4') { [200, { 'Content-Type' => 'application/json' }, MultiJson.encode(results_without_next_page)] }
      end

      subject.apids(4)
    end

    it 'raises an error when the request fails' do
      stub_requests do |stub|
        stub.get('/api/apids/?page=') { [500, {}, ''] }
      end

      expect {
        subject.apids
      }.to raise_error(Zeppelin::ClientError)
    end
  end

  describe '#push' do
    let(:uri) { '/api/push/' }

    let(:payload) { { :device_tokens => [device_token], :aps => { :alert => 'Hello from Urban Airship!' } } }

    it 'is true when the request is successful' do
      stub_requests do |stub|
        stub.post(uri, MultiJson.encode(payload)) { [200, {}, ''] }
      end

      subject.push(payload).should be_true
    end

    it 'raises an error when the request fails' do
      stub_requests do |stub|
        stub.post(uri, '{}') { [400, {}, ''] }
      end

      expect {
        subject.push({})
      }.to raise_error(Zeppelin::ClientError)
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

    let(:uri) { '/api/push/batch/' }

    it 'is true when the request was successful' do
      stub_requests do |stub|
        stub.post(uri, MultiJson.encode(payload)) { [200, {}, ''] }
      end

      subject.batch_push(message1, message2).should be_true
    end

    it 'raises an error when the request fails' do
      stub_requests do |stub|
        stub.post('/api/push/batch/', '[{},{}]') { [400, {}, ''] }
      end

      expect {
        subject.batch_push({}, {})
      }.to raise_error(Zeppelin::ClientError)
    end
  end

  describe '#broadcast' do
    let(:payload) {  { :aps => { :alert => 'Hello from Urban Airship!' } } }

    let(:uri) { '/api/push/broadcast/' }

    it 'is true when the request is successful' do
      stub_requests do |stub|
        stub.post(uri, MultiJson.encode(payload)) { [200, {}, ''] }
      end

      subject.broadcast(payload).should be_true
    end

    it 'raises an error when the request fails' do
      stub_requests do |stub|
        stub.post(uri, '{}') { [400, {}, ''] }
      end

      expect {
        subject.broadcast({})
      }.to raise_error(Zeppelin::ClientError)
    end
  end

  describe '#feedback' do
    let(:response_body) { { 'foo' => 'bar' } }

    let(:since) { Time.at(0) }

    let(:uri) { '/api/device_tokens/feedback/?since=1970-01-01T00%3A00%3A00Z' }

    it 'is the response body for a successful request' do
      stub_requests do |stub|
        stub.get(uri) { [200, { 'Content-Type' => 'application/json' }, MultiJson.encode(response_body)] }
      end

      subject.feedback(since)
    end

    it 'raises an error when the request fails' do
      stub_requests do |stub|
        stub.get(uri) { [400, {}, ''] }
      end

      expect {
        subject.feedback(since)
      }.to raise_error(Zeppelin::ClientError)
    end
  end

  describe '#modify_device_token_on_tag' do
    let(:tag_name) { 'jimmy.page' }

    let(:device_token) { 'CAFEBABE' }

    it 'requets to modify device tokens on a tag' do
      stub_requests do |stub|
        stub.post("/api/tags/#{tag_name}") { [200, {}, 'OK'] }
      end

      subject.modify_device_tokens_on_tag(tag_name, { 'device_tokens' => { 'add' => [device_token] } }).should be
    end
  end

  describe '#add_tag' do
    let(:tag_name) { 'chunky.bacon' }

    it 'is true when the request is successful' do
      stub_requests do |stub|
        stub.put("/api/tags/#{tag_name}") { [201, {}, ''] }
      end

      subject.add_tag(tag_name).should be_true
    end
  end

  describe '#remove_tag' do
    let(:tag_name) { 'cats.pajamas' }

    it 'is true when the request is successful' do
      stub_requests do |stub|
        stub.delete("/api/tags/#{tag_name}") { [204, {}, ''] }
      end

      subject.remove_tag(tag_name).should be_true
    end

    it 'is false when the request fails' do
      stub_requests do |stub|
        stub.delete("/api/tags/#{tag_name}") { [404, {}, ''] }
      end

      expect {
        subject.remove_tag(tag_name)
      }.to raise_error(Zeppelin::ResourceNotFound)
    end
  end

  describe '#device_tags' do
    let(:response_body) { { 'tags' => ['tag1', 'some_tag'] } }

    let(:uri) { "/api/device_tokens/#{device_token}/tags/" }

    it 'is the collection of tags on a device when request is successful' do
      stub_requests do |stub|
        stub.get(uri) { [200, { 'Content-Type' => 'application/json' }, MultiJson.encode(response_body)] }
      end

      subject.device_tags(device_token).should eq(response_body)
    end

    it 'raises an error when the request fails' do
      stub_requests do |stub|
        stub.get(uri) { [404, {}, 'Not Found'] }
      end

      expect {
        subject.device_tags(device_token)
      }.to raise_error(Zeppelin::ResourceNotFound)
    end
  end

  describe '#add_tag_to_device' do
    let(:tag_name) { 'radio.head' }

    let(:uri) { "/api/device_tokens/#{device_token}/tags/#{tag_name}" }

    it 'is true when the request is successful' do
      stub_requests do |stub|
        stub.put(uri) { [201, {}, 'Created'] }
      end

      subject.add_tag_to_device(device_token, tag_name).should be_true
    end

    it 'raises an error when the request fails' do
      stub_requests do |stub|
        stub.put(uri) { [404, {}, ''] }
      end

      expect {
        subject.add_tag_to_device(device_token, tag_name)
      }.to raise_error(Zeppelin::ResourceNotFound)
    end
  end

  describe '#remove_tag_from_device' do
    let(:tag_name) { 'martin.fowler' }

    let(:uri) { "/api/device_tokens/#{device_token}/tags/#{tag_name}" }

    it 'is true when the request is successful' do
      stub_requests do |stub|
        stub.delete(uri) { [204, {}, 'No Content'] }
      end

      subject.remove_tag_from_device(device_token, tag_name).should be_true
    end

    it 'raises an error when the request fails' do
      stub_requests do |stub|
        stub.delete(uri) { [404, {}, ''] }
      end

      expect {
        subject.remove_tag_from_device(device_token, tag_name)
      }.to raise_error(Zeppelin::ResourceNotFound)
    end
  end

  def stub_requests
    subject.connection.builder.handlers.delete(Faraday::Adapter::NetHttp)
    subject.connection.adapter :test do |stubs|
      yield(stubs)
    end
  end
end
