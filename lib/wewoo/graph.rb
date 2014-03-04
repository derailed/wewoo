require 'typhoeus'
require 'json'
require 'map'
require 'wewoo/adapter'

module Wewoo
  class Graph
    include Adapter

    class UnknownGraphError         < RuntimeError; end
    class GraphElementNotFoundError < RuntimeError; end

    attr_reader :url, :name

    def self.available_graphs
      res = Adapter::get( "#{Configuration.url}/graphs" )
      res.graphs
    end

    def initialize( graph_name, host:nil, port:nil )
      Configuration.url( host, port )

      @name     = graph_name
      @base_url = "#{Configuration.url}/graphs"
      @url      = "#{@base_url}/#{@name}"
      validate
    end

    def save( filename )
      dir = File.dirname( filename )
      FileUtils.mkdir_p( dir ) unless File.exists?( dir )

      q( "g.saveGraphML( '#{filename}' )" )
    end

    def load( filename, append:false )
      raise "Graph file does not exist. #{filename}" unless File.exists?(filename)

      clear unless append
      q( "g.loadGraphML( '#{filename}' )" )
    end

    def clear
      query( 'g.V.remove()')
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

    def ensure_index( key, type=:vertex )
      unless key_indices[type.to_s].include? key.to_s
        post( u( %W[keyindices #{type} #{key}] ) )
      end
    end

    def index( index_name, clazz:'vertex', options:{} )
      post( u(%W[indices #{index_name}]), params: {class: clazz}.merge(options))
    end

    def query( command, page:nil, per_page:nil )
      # command = "g." + command unless command[/\Ag\./]
      ResultSet.new( self, get( u(%w[tp gremlin]),
           params:{script: command}.merge(page_params(page, per_page)),
           headers: { 'Content-Type'=> 'application/json'} ) ).hydrate
    end
    alias :q :query

    def add_vertex( props={} )
      vertex = Vertex.from_hash( self,
                                 post( u( %W[vertices] ) ) )
      update_vertex( vertex.id, props )
    end

    # BOZO!! - not really an update as all props will be replaced!
    def update_vertex( id, props )
      v = find_vertex( id )
      props = v.props.merge( props )
      res = put( u( %W[vertices #{id}] ),
            body:    props.to_json,
            headers: { 'Content-Type'=> 'application/json'} )
      Vertex.from_hash( self, res )
    end

    def vertices( page:nil, per_page:nil )
      get( u(:vertices), {params: page_params(page, per_page)} ).map do |res|
        Vertex.from_hash( self, res )
      end
    end
    alias :V :vertices

    def find_vertices( key, value, page:nil, per_page:nil )
      params = { key: key, value: map_value(value) }.merge page_params( page, per_page )
      res    = get( u(:vertices), params:  params )

      res.map do |res|
        Vertex.from_hash( self, res )
      end
    end
    def find_first_vertex( key, value )
      find_vertices( key, value ).first
    end
    def find_vertex_by_gid( gid )
      find_first_vertex( :gid, gid )
    end
    def find_vertex( id )
      Vertex.from_hash( self, get( u %W[vertices #{id}] ) )
    rescue InvalidRequestError => ex
      raise GraphElementNotFoundError, ex.message
    end
    alias :v :find_vertex

    def vertex_exists?( id )
      v(id) && true
    rescue
      false
    end

    def edge_exists?( id )
      e(id) && true
      true
    rescue
      false
    end

    def remove_vertex( id )
      delete( u(%W[vertices #{id}] ) )
    end

    def update_edge( id, props )
      e     = find_edge( id )
      props = e.props.merge( props )

      res = put( u( %W[edges #{id}] ),
            body: props.to_json,
            headers: { 'Content-Type'=> 'application/json'} )
      Edge.from_hash( self, res )
    end

    def add_edge( from, to, label, props={} )
      params = {
        '_outV'  => (from.is_a? Vertex) ? from.id : from,
        '_inV'   => (to.is_a? Vertex) ? to.id : to,
        '_label' => label
      }.merge( props )
      res = post( u( %W[edges] ),
            body: params.to_json,
            headers: { 'Content-Type'=> 'application/json'} )
      Edge.from_hash( self, res )
    end

    def remove_edge( id )
      delete( u %W[edges #{id}] )
    end

    def find_edge( id )
      Edge.from_hash( self, get( u %W[edges #{id}] ) )
    rescue InvalidRequestError => ex
      raise GraphElementNotFoundError, ex.message
    end
    alias :e :find_edge

    def find_edges( key, value, page:nil, per_page:nil )
      params = { key: key,
                 value: map_value( value )
      }.merge page_params( page, per_page )
      get( u(:edges), params: params ).map { |e| Edge.from_hash( self, e ) }
    end

    def find_first_edge( key, value )
      find_edges( key, value, page:1, per_page:1 ).first
    end

    def edges( page:nil, per_page:nil )
      get( u(:edges), params: page_params(page, per_page) ).map do |res|
        Edge.from_hash( self, res )
      end
    end
    alias :E :edges

    def to_s
      res = get( url, headers: { 'Content-Type' =>
                                 'application/vnd.rexster-typed-v1+json' } )
      stats = res.graph.match( /.*\[vertices:(\d+) edges:(\d+)\]/ ).captures

      "#{name} [Vertices:#{stats.first}, Edges:#{stats.last}]"
    end
    alias inspect to_s

    private

    def map_value( value )
      case value
        when TrueClass
        when FalseClass
          "(b,#{value})"
        when Fixnum
          "(i,#{value})"
        when Float
          "(d,#{value})"
      else
        value
      end
    end

    def u( path )
      File.join( url, ((path.is_a? Array) ? path : path.to_s ) )
    end

    def validate
      res = get( @base_url )

      unless res.graphs.include?( @name.to_s )
        raise UnknownGraphError, "Unable to locate graph named `#{@name}"
      end
    end

    def page_params( page, per_page )
      return {} unless page and per_page

      { 'rexster.offset.start' => (page-1)*per_page,
        'rexster.offset.end'   => page*per_page }
    end
  end
end
