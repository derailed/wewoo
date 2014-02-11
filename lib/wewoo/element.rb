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
      @graph      = graph
      @id         = id
      @properties = to_props( properties )
    end

    def to_props( properties )
      props = {}
      properties.each_pair do |k,v|
        value = ((v.is_a? Hash and v.has_key? 'type') ? v['value'] : v)
        props[k] = value
      end
      Map( props )
    end
  end
end
