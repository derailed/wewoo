module Wewoo
  # BOZO !! Need to support chaining!
  class Vertex < Wewoo::Element
    include Adapter

    class InvalidDirectionError < RuntimeError; end

    def self.from_hash( graph, hash )
      hash.delete( '_type' )
      Vertex.new( graph, hash.delete('_id'), Map( hash ) )
    end

    def get_edges( direction, labels=[] )
      str_labels = labels.map(&:to_s)
      get( u(map_direction(direction,true)) ).map { |hash|
        if labels.empty? or str_labels.include? hash['_label']
          Edge.from_hash( graph, hash )
        end
      }.compact
    end
    def outE ( labels=[] ); get_edges( :out  , labels ); end
    def inE  ( labels=[] ); get_edges( :in   , labels ); end
    def bothE( labels=[] ); get_edges( :both , labels ); end

    def get_vertices( direction, labels=[] )
      get_edges(direction,labels).map{ |e|
        if direction == :both
          e.in == self ? e.out : e.in
        else
          e.get_vertex( direction==:in ? :out : :in )
        end
      }
    end
    def out ( labels=[] ); get_vertices( :out  , labels ); end
    def in  ( labels=[] ); get_vertices( :in   , labels ); end
    def both( labels=[] ); get_vertices( :both , labels ); end

    def query
    end

    def ==( other )
      self.gid == other.gid and self.properties == other.properties
    end

    def to_s
     "v(#{self.gid})"
    end
    alias :inspect :to_s

    private

    def u( path )
      File.join( graph.url, %W[vertices #{gid} #{path}] )
    end

    def map_direction( direction, edge=nil )
      raise InvalidDirectionError unless %w[in out both].include? direction.to_s
      direction.to_s + (edge ? "E" : "" )
    end
  end
end
