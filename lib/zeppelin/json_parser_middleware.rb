require 'multi_json'

class Zeppelin
  # Middleware for Faraday that parses JSON response bodies. Based on code in
  # the FaradayMiddleware project.
  #
  # @private
  class JsonParserMiddleware < Faraday::Middleware
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
      env[:response_headers][CONTENT_TYPE].to_s =~ /\bjson$/
    end

    def parse_response?(env)
      env[:body].respond_to? :to_str
    end
  end
end
