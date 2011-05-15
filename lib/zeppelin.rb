require 'faraday'
require 'yajl'
require 'time'

class Zeppelin
  BASE_URI = 'https://go.urbanairship.com'
  PUSH_URI = '/api/push/'
  BATCH_PUSH_URI = '/api/push/batch/'
  BROADCAST_URI = '/api/push/broadcast/'
  SUCCESSFUL_STATUS_CODES = (200..299)
  JSON_HEADERS = { 'Content-Type' => 'application/json' }
  
  attr_reader :connection
  
  def initialize(application_key, application_master_secret)
    @connection = Faraday::Connection.new(BASE_URI) do |builder|
      builder.request :json
      builder.adapter :net_http
    end
    
    @connection.basic_auth(application_key, application_master_secret)
  end
  
  def register_device_token(device_token, payload = {})
    uri = device_token_uri(device_token)
    
    if payload.empty?
      response = @connection.put(uri)
    else
      response = @connection.put(uri, payload, JSON_HEADERS)
    end
    
    successful?(response)
  end
  
  def device_token(device_token)
    response = @connection.get(device_token_uri(device_token))
    successful?(response) ? Yajl::Parser.parse(response.body) : nil
  end
  
  def delete_device_token(device_token)
    response = @connection.delete(device_token_uri(device_token))
    successful?(response)
  end
  
  def push(payload)
    response = @connection.post(PUSH_URI, payload, JSON_HEADERS)
    successful?(response)
  end
  
  def batch_push(*payload)
    response = @connection.post(BATCH_PUSH_URI, payload, JSON_HEADERS)
    successful?(response)
  end
  
  def broadcast(payload)
    response = @connection.post(BROADCAST_URI, payload, JSON_HEADERS)
    successful?(response)
  end
  
  def feedback(since)
    response = @connection.get(feedback_uri(since))
    successful?(response) ? Yajl::Parser.parse(response.body) : nil
  end
  
  private
  
  def device_token_uri(device_token)
    "/api/device_tokens/#{device_token}"
  end
  
  def feedback_uri(since)
    "/api/device_tokens/feedback/?since=#{since.utc.iso8601}"
  end
  
  def successful?(response)
    SUCCESSFUL_STATUS_CODES.include?(response.status)
  end
end

require 'zeppelin/version'