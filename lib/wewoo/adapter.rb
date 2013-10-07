require 'typhoeus'
require 'json'
require 'map'

module Wewoo
  module Adapter
    class NoDataError           < RuntimeError; end
    class InvalidRequestError   < RuntimeError; end

    def get( url, opts={} )
      handle_response( Typhoeus.get( url, opts ) )
    end

    def post( url, opts )
      handle_response( Typhoeus.post( url, opts ) )
    end

    def delete( url, opts={} )
      handle_response( Typhoeus.delete( url, opts ) )
    end

    def handle_response( resp )
      if const_defined? Rails
        Rails.logger.info ">> Wewoo URL: #{resp.effective_url}"
      else
        puts ">> Wewoo URL: #{resp.effective_url}"
      end

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
