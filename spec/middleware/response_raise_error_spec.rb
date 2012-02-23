require 'spec_helper'

describe Zeppelin::Middleware::ResponseRaiseError do
  subject do
    Faraday.new do |b|
      b.use(described_class)
      b.adapter :test do |stub|
        stub.get('ok')        { [200, { 'Content-Type' => 'text/html' }, '<body></body>'] }
        stub.get('not-found') { [404, { 'X-Reason' => 'because' }, 'keep looking'] }
        stub.get('error')     { [500, { 'X-Error' => 'bailout' }, 'fail' ] }
      end
    end
  end

  it 'does nothing when the response is successful' do
    expect {
      subject.get('ok')
    }.to_not raise_error
  end

  it 'raises an error when the resource was not found' do
    expect {
      subject.get('not-found')
    }.to raise_error(Zeppelin::ResourceNotFound)
  end

  it 'raises an error when a client error occurs' do
    expect {
      subject.get('error')
    }.to raise_error(Zeppelin::ClientError)
  end
end
