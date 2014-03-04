module Wewoo
  class Element
    attr_reader   :id, :graph
    attr_accessor :properties

    alias :props :properties

    def gid
      props.gid
    end

    private

    def initialize( graph, id, properties )
      @graph            = graph
      @id               = id
      @properties       = to_props( properties )
      @properties[:gid] = id unless props[:gid]
    end

    def to_props( properties )
      properties.delete( '_type' )
      Map[Hash[properties.map { |k,v|
        [k, ((v.is_a? Hash and v.has_key? 'type') ? v['value'] : v)]
      }]]
    end
  end
end
