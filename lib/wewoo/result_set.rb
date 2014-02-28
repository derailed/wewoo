# BOZO !! Refactor
module Wewoo
  class ResultSet

    def initialize( graph, results )
      @results = results
      @graph   = graph
    end

    def graph_element?( item )
      item.is_a? Hash and item.key?('_type')
    end

    def build_element( item )
      type = item['_type']
      Object.const_get( "Wewoo::#{type.capitalize}" )
            .from_hash( @graph, item )
    end

    def hydrate
      return @results if @results.is_a? Hash

      if @results.is_a? Array and @results.size == 1
        @results = @results.first
      end

      return build_element( @results ) if graph_element? @results

      return_type = nil
      out = @results.map do |r|
        if graph_element? r
          build_element( r )
        elsif r.is_a? Hash
          return_type = :hash
          r.map do |k,v|
            obj = build_element( v )
            {k => obj}
          end
        elsif r.is_a? Array and r.last.is_a? Hash and
              r.last.key?('_value') and r.last.key?('_key')
          element = r.last
          obj = build_element( element['_key'] )
          return_type = :hash
          [obj, element['_value']]
        elsif r.is_a? Array
          r.map{ |item|
            if graph_element? item
              build_element( item )
            else
              item
            end
          }
        else
          r
        end
      end
     return_type == :hash ? Hash[*out.flatten] : out
    rescue => boom
      #puts boom
      #boom.backtrace.each{ |l| puts l }
      @results
    end
  end
end
