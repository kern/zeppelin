require 'multi_json'

class Zeppelin
  module Middleware
    # Middleware for Faraday that parses JSON response bodies. Based on code in
    # the FaradayMiddleware project.
    #
    # @private
    class JsonParser < Faraday::Middleware
      CONTENT_TYPE = 'Content-Type'

      def initialize(app=nil)
        @app = app
      end

      def call(env)
        @app.call(env).on_complete do
          parse_response(env) if process_content_type?(env) && parse_response?(env)
        end
      end

      private

      def parse_response(env)
        env[:body] = MultiJson.decode(env[:body])
      end

      def process_content_type?(env)
        env[:response_headers][CONTENT_TYPE].to_s =~ /application\/(.*)json/
      end

      def parse_response?(env)
        env[:body].respond_to? :to_str
      end
    end
  end
end
