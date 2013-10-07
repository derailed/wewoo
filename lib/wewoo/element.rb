module Wewoo
  class Element
    attr_reader   :gid, :graph
    attr_accessor :properties

    private

    def initialize( graph, gid, properties )
      @graph      = graph
      @gid        = gid
      @properties = to_props( properties )
    end
    alias :props :properties

    def to_props( properties )
      Map( *properties.map{ |k,v| [k,(v.is_a?(Hash) ? v['value'] : v)] }.flatten )
    end
  end
end
