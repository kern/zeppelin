class Zeppelin
  module Middlware
  end
end

require 'zeppelin/middleware/response_raise_error'

Faraday.register_middleware :response, zeppelin_raise_error: Zeppelin::Middleware::ResponseRaiseError
