require 'typhoeus'
require 'json'
require 'map'

module Wewoo
  module Adapter
    module_function

    class NoDataError           < RuntimeError; end
    class InvalidRequestError   < RuntimeError; end

    def get( url, opts={} )
      handle_response( Typhoeus.get( url, opts ) )
    end

    def post( url, opts={} )
      handle_response( Typhoeus.post( url, opts ) )
    end

    def delete( url, opts={} )
      handle_response( Typhoeus.delete( url, opts ) )
    end

    def log( message )
      return unless Configuration.debug

      msg = "[Wewoo] #{message}"
      if Object.const_defined? :Rails
        Rails.logger.info msg
      else
        puts msg
      end
    end

    def handle_response( resp )
      log "URL: #{resp.effective_url}"

      unless resp.success?        
        error = "-- " + JSON.parse( resp.response_body )['message'] rescue ""        
        raise InvalidRequestError, "<#{resp.response_code}> " + 
              "Failed request:#{resp.effective_url} #{error}" 
      end

      if resp.body.empty? or resp.body == "null"
        raise NoDataError, "No data found at location #{url}"
      end
    
      body = JSON.parse( resp.body ) 
   
      results = body['results'] || body
      results.is_a?(Hash) ? Map( results ) : results
    end 
  end
end
