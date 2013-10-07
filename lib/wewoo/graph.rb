require 'typhoeus'
require 'json'
require 'map'
require 'wewoo/adapter'

module Wewoo
  class Graph
    include Adapter

    class UnknownGraphError < RuntimeError; end

    attr_reader :url, :name

    def self.available_graphs
      res = Adapter::get( "#{Configuration.url}/graphs" )
      res.graphs
    end

    def initialize( name )
      @name = name
      @base_url = "#{Configuration.url}/graphs"
      @url      = "#{@base_url}/#{@name}"
      validate
    end

    # BOZO !! Got to be a better way... 
    def clear
      vertices.each { |v| delete( u %W[vertices #{v.gid}] ) }
      edges.each    { |e| delete( u %W[edges    #{e.gid}] ) }
    end

    def key_indices
      Map[ *get( u(:keyindices ) ).flatten]
    end

    def set_key_index( type, key )
      post( u( %W[keyindices #{type} #{key}] ) )
    end

    def drop_index( index_name )
      delete( u( %W[indices #{index_name}] ) )
    end

    def index( index_name, clazz:'vertex', options:{} )
      post( u(%W[indices #{index_name}]), params: {class: clazz}.merge(options))
    end

    def query( command, page:nil, per_page:nil )
      hydrate get( u(%w[tp gremlin]),
                   params:{script: command}.merge(page_params(page, per_page)))
    end

    def add_vertex( props={} )
      id = props.delete(:id)
      if id
        Vertex.from_hash( self, post(u(%W[vertices #{id}]), params: props))
      else
        v = Vertex.from_hash( self, post(u :vertices) )
        unless props.empty?
          Vertex.from_hash(self, post(u(%W[vertices #{v.gid}]), params:props))
        end
      end
    end

    def vertices( page:nil, per_page:nil )
      get( u(:vertices), {params: page_params(page, per_page)} ).map do |res| 
        Vertex.from_hash( self, res ) 
      end
    end
    alias :V :vertices

    def get_vertex( id )
     Vertex.from_hash( self, get( u %W[vertices #{id}] ) )
    end
    alias :v :get_vertex

    def get_vertices( key, value, page:nil, per_page:nil )
      params = { key: key, value: value }.merge page_params( page, per_page )

      res    = get( u(:vertices), params: params )
      res.map do |res|
        Vertex.from_hash( self, res )
      end
    end

    def remove_vertex( id )
      delete( u(%W[vertices #{id}] ) )
    end

    def add_edge( from_id, to_id, label, props={} )
      id = props.delete(:id)
      params = {
        '_outV'  => from_id,
        '_inV'   => to_id,
        '_label' => label 
      }.merge( props )
   
      if id
        Edge.from_hash( self, post( u(%W[edges #{id}]), {params: params} ) )
      else
        Edge.from_hash( self, post( u(:edges), {params: params} ) )
      end
    end

    def remove_edge( gid )
      delete( u %W[edges #{gid}] )
    end

    def get_edge( gid )
      Edge.from_hash( self, get( u %W[edges #{gid}] ) )
    end
    alias :e :get_edge

    def get_edges( key, value )
      params = { key: key, value: value }
      get( u(:edges), params: params ).map do |e|
        Edge.from_hash( self, e )
      end
    end

    def edges( page:nil, per_page:nil )
      get( u(:edges), params: page_params(page, per_page) ).map do |res|
        Edge.from_hash( self, res )
      end
    end
    alias :E :edges

    def to_s
      name
    end
    alias inspect to_s

    private

    def u( path )
      File.join( url, ((path.is_a? Array) ? path : path.to_s ) )
    end

    def validate
      resp = Typhoeus.get( @base_url)
      res  = handle_response( resp )

      unless res.graphs.include?( @name.to_s )
        raise UnknownGraphError, "Unable to locate graph named `#{@name}"
      end
    end

    # BOZO !! This is wrong 
    def hydrate( res )
      res.map do |r|
        type = r.delete( '_type' )
        if type
          Object.const_get( "Wewoo::#{type.capitalize}" ).from_hash( self, r )
        else
          r
        end
      end
    end

    def page_params( page, per_page )
      return {} unless page and per_page
      
      { 'rexster.offset.start' => (page-1)*per_page,
        'rexster.offset.end'   => page*per_page }
    end
  end
end
