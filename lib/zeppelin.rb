require 'faraday'
require 'yajl'
require 'time'

# A very tiny Urban Airship Push Notification API client.
# 
# Provides thin wrappers around API calls to the most common API tasks. For more
# information on how the requests and responses are formatted, visit the [Urban
# Airship Push Notification API docs](http://urbanairship.com/docs/push.html).
class Zeppelin
  BASE_URI = 'https://go.urbanairship.com'
  PUSH_URI = '/api/push/'
  BATCH_PUSH_URI = '/api/push/batch/'
  BROADCAST_URI = '/api/push/broadcast/'
  SUCCESSFUL_STATUS_CODES = (200..299)
  JSON_HEADERS = { 'Content-Type' => 'application/json' }
  
  # The connection to `https://go.urbanairship.com`.
  attr_reader :connection
  
  # Creates a new client.
  # 
  # @param [String] application_key your Urban Airship Application Key
  # @param [String] application_master_secret your Urban Airship Application
  #   Master Secret
  def initialize(application_key, application_master_secret)
    @connection = Faraday::Connection.new(BASE_URI) do |builder|
      builder.request :json
      builder.adapter :net_http
    end
    
    @connection.basic_auth(application_key, application_master_secret)
  end
  
  # Registers a device token.
  # 
  # @param [String] device_token
  # @param [Hash] payload the payload to send during registration
  # @return [Boolean] whether or not the registration was successful
  def register_device_token(device_token, payload = {})
    uri = device_token_uri(device_token)
    
    if payload.empty?
      response = @connection.put(uri)
    else
      response = @connection.put(uri, payload, JSON_HEADERS)
    end
    
    successful?(response)
  end
  
  # Retrieves information on a device token.
  # 
  # @param [String] device_token
  # @return [Hash, nil]
  def device_token(device_token)
    response = @connection.get(device_token_uri(device_token))
    successful?(response) ? parse(response.body) : nil
  end
  
  # Deletes a device token.
  # 
  # @param [String] device_token
  # @return [Boolean] whether or not the deletion was successful
  def delete_device_token(device_token)
    response = @connection.delete(device_token_uri(device_token))
    successful?(response)
  end
  
  # Registers an APID.
  # 
  # @param [String] apid
  # @param [Hash] payload the payload to send during registration
  # @return [Boolean] whether or not the registration was successful
  def register_apid(apid, payload = {})
    uri = apid_uri(apid)
    
    if payload.empty?
      response = @connection.put(uri)
    else
      response = @connection.put(uri, payload, JSON_HEADERS)
    end
    
    successful?(response)
  end
  
  # Retrieves information on an APID.
  # 
  # @param [String] apid
  # @return [Hash, nil]
  def apid(apid)
    response = @connection.get(apid_uri(apid))
    successful?(response) ? parse(response.body) : nil
  end
  
  # Deletes an APID.
  # 
  # @param [String] apid
  # @return [Boolean] whether or not the deletion was successful
  def delete_apid(apid)
    response = @connection.delete(apid_uri(apid))
    successful?(response)
  end
  
  # Pushes a message.
  # 
  # @param [Hash] payload the payload of the message
  # @return [Boolean] whether or not pushing the message was successful
  def push(payload)
    response = @connection.post(PUSH_URI, payload, JSON_HEADERS)
    successful?(response)
  end
  
  # Batch pushes multiple messages.
  # 
  # @param [<Hash>] payload the payloads of each message
  # @return [Boolean] whether or not pushing the messages was successful
  def batch_push(*payload)
    response = @connection.post(BATCH_PUSH_URI, payload, JSON_HEADERS)
    successful?(response)
  end
  
  # Broadcasts a message.
  # 
  # @param [Hash] payload the payload of the message
  # @return [Boolean] whether or not broadcasting the message was successful
  def broadcast(payload)
    response = @connection.post(BROADCAST_URI, payload, JSON_HEADERS)
    successful?(response)
  end
  
  # Retrieves feedback on device tokens.
  # 
  # This is useful for removing inactive device tokens for the database.
  # 
  # @param [Time] since the time to retrieve inactive tokens from
  # @return [Hash, nil]
  def feedback(since)
    response = @connection.get(feedback_uri(since))
    successful?(response) ? parse(response.body) : nil
  end

  # Retrieve all tags on the service
  #
  # @return [Hash, nil]
  def tags
    response = @connection.get(tag_uri(nil))
    successful?(response) ? parse(response.body) : nil
  end

  # Modifies device tokens associated with a tag.
  #
  # @param [String] tag The name of the tag to modify tag associations on
  #
  # @param [Hash] payload
  #
  # @see http://urbanairship.com/docs/tags.html#modifying-device-tokens-on-a-tag
  def modify_device_tokens_on_tag(tag_name, payload = {})
    @connection.post(tag_uri(tag_name), payload, JSON_HEADERS)
  end

  # Creates a tag that is not associated with any device
  #
  # @param [#to_s] name The name of the tag to add
  #
  # @return [Boolean] whether or not the request was successful
  def add_tag(name)
    response = @connection.put(tag_uri(name))
    successful?(response)
  end

  # Removes a tag from the service
  #
  # @param [#to_s] name The name of the tag to remove
  #
  # @return [Boolean] true when the request was successful. Note that this
  #   method will return false if the tag has already been removed.
  def remove_tag(name)
    response = @connection.delete(tag_uri(name))
    successful?(response)
  end

  # @param [String] device_token
  #
  # @return [Hash, nil]
  def device_tags(device_token)
    response = @connection.get(device_tag_uri(device_token, nil))
    successful?(response) ? parse(response.body) : nil
  end

  # @param [String] device_token
  #
  # @param [#to_s] tag_name
  #
  # @return [Boolean] whether or not a tag was successfully associated with
  #   a device
  def add_tag_to_device(device_token, tag_name)
    response = @connection.put(device_tag_uri(device_token, tag_name))
    successful?(response)
  end

  # @param [String] device_token
  #
  # @param [#to_s] tag_name
  #
  # @return [Boolean] whether or not a tag was successfully dissociated from
  #   a device
  def remove_tag_from_device(device_token, tag_name)
    response = @connection.delete(device_tag_uri(device_token, tag_name))
    successful?(response)
  end
  
  private
  
  def device_token_uri(device_token)
    "/api/device_tokens/#{device_token}"
  end
  
  def apid_uri(apid)
    "/api/apids/#{apid}"
  end
  
  def feedback_uri(since)
    "/api/device_tokens/feedback/?since=#{since.utc.iso8601}"
  end

  def tag_uri(name)
    "/api/tags/#{name}"
  end

  def device_tag_uri(device_token, tag_name)
    device_token_uri(device_token) + "/tags/#{tag_name}"
  end
  
  def successful?(response)
    SUCCESSFUL_STATUS_CODES.include?(response.status)
  end

  def parse(json)
    Yajl::Parser.parse(json)
  end
end

require 'zeppelin/version'
