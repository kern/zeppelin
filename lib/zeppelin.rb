require 'faraday'
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
  JSON_HEADERS = { 'Content-Type' => 'application/json' }

  attr_reader :application_key, :application_master_secret, :options

  # @param [String] application_key your Urban Airship Application Key
  #
  # @param [String] application_master_secret your Urban Airship Application
  #   Master Secret
  def initialize(application_key, application_master_secret, options = {})
    @application_key = application_key
    @application_master_secret = application_master_secret
    @options = options
  end

  # The connection to UrbanAirship
  def connection
    return @connection unless @connection.nil?
    @connection = initialize_connection
  end

  # Registers a device token.
  #
  # @param [String] device_token
  # @param [Hash] payload the payload to send during registration
  #
  # @return [Boolean] whether or not the registration was successful
  #
  # @raise [Zeppelin::ClientError] malformed request
  def register_device_token(device_token, payload = {})
    uri = device_token_uri(device_token)
    put_request(uri, payload)
  end

  # Retrieves information on a device token.
  #
  # @param [String] device_token
  # @return [Hash, nil]
  #
  # @raise [Zeppelin::ResourceNotFound] invalid device token provided
  def device_token(device_token)
    uri = device_token_uri(device_token)
    get_request(uri)
  end

  # Deletes a device token.
  #
  # @param [String] device_token
  #
  # @return [Boolean] whether or not the deletion was successful
  #
  # @raise [Zeppelin::ResourceNotFound] invalid device token provided
  def delete_device_token(device_token)
    uri = device_token_uri(device_token)
    delete_request(uri)
  end

  # Registers an APID.
  #
  # @param [String] apid
  #
  # @param [Hash] payload the payload to send during registration
  #
  # @return [Boolean] whether or not the registration was successful
  #
  # @raise [Zeppelin::ClientError] invalid payload format
  def register_apid(apid, payload = {})
    uri = apid_uri(apid)
    put_request(uri, payload)
  end

  # Retrieves information on an APID.
  #
  # @param [String] apid
  #
  # @return [Hash, nil]
  #
  # @raise [Zeppelin::ResourceNotFound] invalid APID provided
  def apid(apid)
    uri = apid_uri(apid)
    get_request(uri)
  end

  # Deletes an APID.
  #
  # @param [String] apid
  #
  # @return [Boolean] whether or not the deletion was successful
  #
  # @raise [Zeppelin::ResourceNotFound] invalid APID provided
  def delete_apid(apid)
    uri = apid_uri(apid)
    delete_request(uri)
  end

  # Pushes a message.
  #
  # @param [Hash] payload the payload of the message
  #
  # @return [Boolean] whether or not pushing the message was successful
  #
  # @raise [Zeppelin::ClientError] invalid payload format
  def push(payload)
    post_request(PUSH_URI, payload)
  end

  # Batch pushes multiple messages.
  #
  # @param [<Hash>] payload the payloads of each message
  #
  # @return [Boolean] whether or not pushing the messages was successful
  #
  # @raise [Zeppelin::ClientError] invalid payload format
  def batch_push(*payload)
    post_request(BATCH_PUSH_URI, payload)
  end

  # Broadcasts a message.
  #
  # @param [Hash] payload the payload of the message
  #
  # @return [Boolean] whether or not broadcasting the message was successful
  #
  # @raise [Zeppelin::ClientError] invalid payload format
  def broadcast(payload)
    post_request(BROADCAST_URI, payload)
  end

  # Retrieves feedback on device tokens.
  #
  # This is useful for removing inactive device tokens for the database.
  #
  # @param [Time] since the time to retrieve inactive tokens from
  #
  # @return [Hash, nil]
  #
  # @raise [Zeppelin::ClientError] invalid time param
  def feedback(since)
    uri = feedback_uri(since)
    get_request(uri)
  end

  # Retrieve all tags on the service
  #
  # @return [Hash, nil]
  def tags
    uri = tag_uri(nil)
    get_request(uri)
  end

  # Modifies device tokens associated with a tag.
  #
  # @param [String] tag The name of the tag to modify tag associations on
  #
  # @param [Hash] payload
  #
  # @see http://urbanairship.com/docs/tags.html#modifying-device-tokens-on-a-tag
  def modify_device_tokens_on_tag(tag_name, payload = {})
    uri = tag_uri(tag_name)
    post_request(uri, payload)
  end

  # Creates a tag that is not associated with any device
  #
  # @param [#to_s] name The name of the tag to add
  #
  # @return [Boolean] whether or not the request was successful
  def add_tag(name)
    uri = tag_uri(name)
    put_request(uri)
  end

  # Removes a tag from the service
  #
  # @param [#to_s] name The name of the tag to remove
  #
  # @return [Boolean] true when the request was successful. Note that this
  #   method will return false if the tag has already been removed.
  #
  # @raise [Zeppelin::ResourceNotFound] tag already removed
  def remove_tag(name)
    uri = tag_uri(name)
    delete_request(uri)
  end

  # @param [String] device_token
  #
  # @return [Hash, nil]
  #
  # @raise [Zeppelin::ResourceNotFound] device does not exist
  def device_tags(device_token)
    uri = device_tag_uri(device_token, nil)
    get_request(uri)
  end

  # @param [String] device_token
  #
  # @param [#to_s] tag_name
  #
  # @return [Boolean] whether or not a tag was successfully associated with
  #   a device
  #
  # @raise [Zeppelin::ResourceNotFound] device does not exist
  def add_tag_to_device(device_token, tag_name)
    uri = device_tag_uri(device_token, tag_name)
    put_request(uri)
  end

  # @param [String] device_token
  #
  # @param [#to_s] tag_name
  #
  # @return [Boolean] whether or not a tag was successfully dissociated from
  #   a device
  #
  # @raise [Zeppelin::ResourceNotFound] device does not exist
  def remove_tag_from_device(device_token, tag_name)
    uri = device_tag_uri(device_token, tag_name)
    delete_request(uri)
  end

  private

  def initialize_connection
    Faraday::Request::JSON.adapter = MultiJson

    conn = Faraday::Connection.new(BASE_URI, @options) do |builder|
      builder.request :json

      builder.use Zeppelin::Middleware::JsonParser
      builder.use Zeppelin::Middleware::ResponseRaiseError

      builder.adapter :net_http
    end

    conn.basic_auth(@application_key, @application_master_secret)

    conn
  end

  def put_request(uri, payload={})
    if !(payload.nil? || payload.empty?)
      response =connection.put(uri, payload, JSON_HEADERS)
    else
      response = connection.put(uri)
    end

    response.success?
  end

  def delete_request(uri)
    connection.delete(uri).success?
  end

  def get_request(uri)
    response = connection.get(uri)
    response.body if response.success?
  end

  def post_request(uri, payload)
    connection.post(uri, payload, JSON_HEADERS).success?
  end

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
end

require 'zeppelin/middleware'
require 'zeppelin/version'
