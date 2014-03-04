# BOZO !! Refactor
module Wewoo
  class ResultSet

    class NoGraphElementError < RuntimeError; end

    def initialize( graph, results )
      @results = results
      @graph   = graph
    end

    def hydrate
      collapse( _hydrate( @results ) )
    end

    def graph_element?( item )
      item.is_a? Hash    and
      item.key?('_type') and
      %w(vertex edge).include? item['_type']
    end

    def build_element( item )
      type = item['_type']
      Object.const_get( "Wewoo::#{type.capitalize}" )
            .from_hash( @graph, item )
    rescue => boom
      raise NoGraphElementError, "Unbuildable"
    end

    private

    def collapse( res )
      (res.is_a? Enumerable and
       res.count == 1 and
       res.first.is_a? Enumerable) ? res.first : res
    end

    def usable( item )
      graph_element?( item ) ? build_element( item ) : item
    end

    def value_hash?( hash )
      hash.values.first.is_a? Hash
    end

    def simple_response?( res )
      res.is_a? Hash and res.key?('success')
    end

    def key_value_hash?( res )
      res.is_a? Hash and res.key?('_key') and res.key?('_value')
    end

    def _deep_hydrate( item, acc )
      if graph_element?( item )
        acc << build_element( item )
      elsif item.is_a? Array
        tuples = []
        item.each do |row|
          _deep_hydrate( row, tuples )
        end
        acc << tuples
      elsif item.is_a? Hash
        if key_value_hash?( item )
          key = usable(item['_key'])
          if item['_value'].is_a? Enumerable
            acc[key] = []
            item['_value'].each do |row|
              acc[key] << usable(row)
            end
          else
            acc[key] = usable(item['_value'])
          end
        elsif item.values.first.is_a? Hash
          res = {}
          item.values.each do |item|
            _deep_hydrate( item, res )
          end
          acc << res
        else
          acc << item
        end
      else
        acc << item
      end
    end

    def _hydrate( res )
      return res['success'] if simple_response?( res )
      if res.is_a? Array
        acc = []
        res.each{ |row| _deep_hydrate( row, acc ) }
        acc
      else
        raise "Unexpected match!!"
      end
    end
  end
end
