module Titanup
  class Vertex < Titanup::Element
    include Adapter

    def self.from_hash( graph, hash )
      hash.delete( '_type' )
      Vertex.new( graph, hash.delete('_id'), Map( hash ) )
    end
   
    def get_edges( direction, labels=[] )
      url = "#{graph.url}/vertices/#{self.gid}/#{map_direction(direction, true)}"
 
      resp = Typhoeus.get( url )
      handle_response(resp).map { |hash| Edge.from_hash( graph, hash ) }
    end

    def get_vertices( direction, labels=[] )
      url = "#{graph.url}/vertices/#{self.gid}/#{map_direction(direction)}"
 
      resp = Typhoeus.get( url )
      handle_response(resp).map { |hash| Vertex.from_hash( graph, hash ) }
    end

    def query
    end

    def ==( other )
      self.gid == other.gid and self.properties == other.properties
    end
    
    def to_s
     "v(#{self.gid})"
    end

    private

    def map_direction( direction, edge=nil )
      direction.to_s + (edge ? "E" : "" )
    end
  end
end
