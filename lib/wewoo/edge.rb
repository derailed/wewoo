require 'wewoo/element'

module Wewoo
  class Edge < Element
    attr_accessor :label, :from_gid, :to_gid

    def self.from_hash( graph, hash )
      hash.delete( '_type' )
      gid  = hash.delete( '_id' )
      from = hash.delete( '_outV' )
      to   = hash.delete( '_inV' )

      Edge.new( graph, gid, from, to, hash.delete('_label'), hash )
    end

    def ==( other )
      self.gid        == other.gid and 
      self.from_gid   == other.from_gid and
      self.to_gid     == other.to_gid and
      self.label      == other.label and 
      self.properties == other.properties
    end

    def get_vertex( direction )
     id = direction == :in ? from_gid : to_gid
     graph.get_vertex( id )
    end

    def to_s
     "e(#{self.gid}) [#{from_gid}-#{label}-#{to_gid}]"
    end

    private
   
    def initialize( graph, gid, from_gid, to_gid, label, properties )
      super( graph, gid, properties )

      @from_gid = from_gid
      @to_gid   = to_gid
      @label    = label
    end
  end
end
