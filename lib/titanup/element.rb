module Titanup
  class Element
    attr_reader   :gid, :graph
    attr_accessor :properties

    private

    def initialize( graph, gid, properties )
      @graph      = graph
      @gid        = gid.to_i.to_i
      @properties = to_props( properties )
    end

    def to_props( properties )
      Map( *properties.map{ |k,v| [k,v['value']||v] }.flatten )
    end
  end
end
