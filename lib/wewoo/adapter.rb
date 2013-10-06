module Wewoo
  module Adapter
    class NoDataError           < RuntimeError; end
    class InvalidRequestError   < RuntimeError; end

    def handle_response( resp )
      unless resp.success?        
        error = "-- " + JSON.parse( resp.body )['error'] rescue ""        
        raise InvalidRequestError,
          "<#{resp.return_code}> Unable to perform request #{url} #{error}" 
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
