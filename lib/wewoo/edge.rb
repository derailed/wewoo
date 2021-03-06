require 'wewoo/element'

module Wewoo
  class Edge < Element
    include Adapter

    attr_accessor :label, :from_id, :to_id

    def ==( other )
      self.class   == other.class and
      self.id      == other.id and
      self.from_id == other.from_id and
      self.to_id   == other.to_id and
      self.label   == other.label and
      self.props   == other.props
    end
    alias :eql? :==
    def hash; id; end

    def get_vertex( direction )
      id = (direction == :in ? to_id : from_id)
      graph.find_vertex( id )
    end
    def in;  @in  || get_vertex(:in); end
    def out; @out || get_vertex(:out); end

    def to_s
      "e(#{self.id}) [#{from_id}-#{label}-#{to_id}]"
    end
    alias :inspect :to_s

    def destroy
      graph.remove_edge( id )
    end

    private

    def self.from_hash( graph, hash )
      new( graph,
           hash.delete( '_id' ),
           hash.delete( '_outV' ),
           hash.delete( '_inV' ),
           hash.delete('_label'), hash )
    end

    def initialize( graph, id, from_id, to_id, label, properties )
      super( graph, id, properties )

      @from_id = from_id
      @to_id   = to_id
      @label   = label
    end
  end
end
