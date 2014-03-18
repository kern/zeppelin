require 'spec_helper'

describe Zeppelin::Middleware::ResponseRaiseError do

  let(:not_found_response) { [404, { 'X-Reason' => 'because' }, 'keep looking'] }
  let(:error_response) { [500, { 'X-Error' => 'bailout' }, 'fail' ] }

  subject do
    Faraday.new do |b|
      b.use(described_class)
      b.adapter :test do |stub|
        stub.get('ok')        { [200, { 'Content-Type' => 'text/html' }, '<body></body>'] }
        stub.get('not-found') { not_found_response }
        stub.get('error')     { error_response }
      end
    end
  end

  it 'does nothing when the response is successful' do
    expect {
      subject.get('ok')
    }.to_not raise_error
  end

  context 'resource not found' do
    it 'raises Zeppelin::ResourceNotFound error' do
      expect {
        subject.get('not-found')
      }.to raise_error(Zeppelin::ResourceNotFound)
    end

    it "does not destroy the response object stored in the error" do
      begin
        subject.get('not-found')
      rescue Zeppelin::ResourceNotFound => ex
        expect(ex.response[:status]).to eql(not_found_response[0])
        expect(ex.response[:headers]).to eql(not_found_response[1])
        expect(ex.response[:body]).to eql(not_found_response[2])
      end
    end
  end

  context 'client error' do
    it 'raises Zeppelin::ClientError error' do
      expect {
        subject.get('error')
      }.to raise_error(Zeppelin::ClientError)
    end

    it "does not destroy the response object stored in the error" do
      begin
        subject.get('error')
      rescue Zeppelin::ClientError => ex
        expect(ex.response[:status]).to eql(error_response[0])
        expect(ex.response[:headers]).to eql(error_response[1])
        expect(ex.response[:body]).to eql(error_response[2])
      end
    end
  end
end
