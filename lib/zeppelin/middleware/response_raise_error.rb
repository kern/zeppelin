class Zeppelin
  class ResourceNotFound < Faraday::Error::ResourceNotFound
  end

  class ClientError < Faraday::Error::ClientError
  end

  module Middleware
    # Intercept Faraday errors and re-raise our own to hide implementation details
    #
    # @private
    class ResponseRaiseError < Faraday::Response::RaiseError
      def on_complete(env)
        super
      rescue Faraday::Error::ResourceNotFound => msg
        raise ResourceNotFound, msg
      rescue Faraday::Error::ClientError => msg
        raise ClientError, msg
      end
    end
  end
end
