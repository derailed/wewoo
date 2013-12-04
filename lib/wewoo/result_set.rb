# BOZO !! Refactor
module Wewoo
  class ResultSet
    
    def initialize( results )
      @results = results      
    end
        
    # BOZO !! This is wrong
    def hydrate
puts @results.inspect
      return @results if @results.is_a? Hash

      if @results.is_a? Array and @results.size == 1
        @results = @results.first
      end

      if @results.is_a? Hash and @results.key?('_type')
        type = @results['_type']
        return [Object.const_get( "Wewoo::#{type.capitalize}" ).from_hash( self, @results )]
      end

      return_type = nil
      out = @results.map do |r|
        if r.is_a? Hash and r.key?('_type')
          type = r['_type']
          Object.const_get( "Wewoo::#{type.capitalize}" ).from_hash( self, r )
        elsif r.is_a? Hash
          r.map do |k,v|
            type = v['_type']
            obj = Object.const_get( "Wewoo::#{type.capitalize}" )
                        .from_hash( self, v )
            {k => obj}
          end
        elsif r.is_a? Array and r.last.is_a? Hash and
              r.last.key?('_value') and r.last.key?('_key')
          element = r.last
          type = element['_key']['_type']
          obj  = Object.const_get( "Wewoo::#{type.capitalize}" )
                       .from_hash( self, element['_key'] )

          return_type = :hash
          [obj, element['_value']]
        elsif r.is_a? Array
          r.map{ |element|
            if element.is_a? Hash
              type = element['_type']
              Object.const_get( "Wewoo::#{type.capitalize}" )
                    .from_hash( self, element )
            else
              element
            end
          }
        else
          r
        end
      end
     if return_type == :hash
       out = Hash[*out.flatten]
     end
puts out.inspect
      out
    rescue => boom
puts boom
boom.backtrace.each{ |l| puts l }
      @results
    end
  end
end