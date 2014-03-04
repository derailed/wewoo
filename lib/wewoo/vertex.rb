module Wewoo
  # BOZO !! Need to support chaining!
  class Vertex < Wewoo::Element
    include Adapter

    def outE ( *labels ); @outE  || get_edges( :outE , labels ); end
    def inE  ( *labels ); @inE   || get_edges( :inE  , labels ); end
    def bothE( *labels ); @bothE || get_edges( :bothE, labels ); end

    def out ( *labels ); @out  || get_vertices( :out , labels ); end
    def in  ( *labels ); @in   || get_vertices( :in  , labels ); end
    def both( *labels ); @both || get_vertices( :both, labels ); end

    def ==( o )
      self.class == o.class and self.id == o.id and self.props == o.props
    end
    alias :eql? :==
    def hash; id; end
    def <=>(o); self.class == o.class ? self.id <=> o.id : super; end

    def destroy
      graph.remove_vertex( id )
    end

    def to_s
     "v(#{self.id})"
    end
    alias :inspect :to_s

    def dump
      props.clone().merge( id: id )
    end

    private

    def get_edges( direction, labels )
      str_labels = labels ? labels.map(&:to_s) : []
      get( u direction ).map { |hash|
        if labels.empty? or str_labels.include? hash['_label']
          Edge.from_hash( graph, hash )
        end
      }.compact
    end

    def get_vertices( direction, labels=[] )
      get_edges( "#{direction}E",labels ).map{ |e|
        if direction == :both
          e.in == self ? e.out : e.in
        else
          e.get_vertex( direction==:in ? :out : :in )
        end
      }
    end

    def self.from_hash( graph, hash )
      new( graph, hash.delete('_id'), Map( hash ) )
    end

    def u( path )
      File.join( graph.url, %W[vertices #{id} #{path}] )
    end
  end
end
