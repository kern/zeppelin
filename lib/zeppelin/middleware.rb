class Zeppelin
  module Middlware
  end
end

require 'zeppelin/middleware/response_raise_error'

# For backwards compatibility with Faraday < 0.9
if Faraday.respond_to?(:register_middleware)
  Faraday.register_middleware :response, zeppelin_raise_error: Zeppelin::Middleware::ResponseRaiseError
else
  Faraday::Response.register_middleware zeppelin_raise_error: Zeppelin::Middleware::ResponseRaiseError
end
