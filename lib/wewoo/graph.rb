require 'typhoeus'
require 'json'
require 'map'
require 'wewoo/adapter'

module Wewoo
  class Graph
    include Adapter

    class UnknownGraphError < RuntimeError; end

    attr_reader :url

    # BOZO !! Validate graph exists!
    def initialize( name )
      @name = name
      @base_url = "#{Configuration.url}/graphs"
      @url      = "#{@base_url}/#{@name}"
      validate
    end

    def clear
      vertices.each { |v| Typhoeus.delete( url + "/vertices/#{v.gid}" ) }
      edges.each    { |e| Typhoeus.delete( url + "/edges/#{e.gid}" ) }
    end

    def query( command )
      resp = Typhoeus.get( url + "/tp/gremlin", {params: {script: command} } )
      res  = handle_response( resp )

      hydrate res
    end

    def add_vertex( id, properties={} )
      resp = Typhoeus.post( url + "/vertices/#{id}", {params: properties} )
      res  = handle_response( resp )
      Vertex.from_hash( self, res )
    end

    def vertices
      resp = Typhoeus.get( url + "/vertices", {} )
      res  = handle_response( resp )
      res.map do |res|
        Vertex.from_hash( self, res )
      end
    end

    def get_vertex( id )
     resp = Typhoeus.get( url + "/vertices/#{id}" )
     res  = handle_response( resp )
     Vertex.from_hash( self, res )
    end

    def get_vertices( key, value )
      params = { key: key, value: value }
      resp = Typhoeus.get( url + "/vertices", params: params )
      res  = handle_response( resp )

      res.map do |res|
        Vertex.from_hash( self, res )
      end
    end

    def remove_vertex( id )
      resp = Typhoeus.delete( url + "/vertices/#{id}" )
      handle_response( resp )
      nil
    end

    def add_edge( id, from_id, to_id, label, properties={} )
      params = {
        '_outV'  => from_id,
        '_inV'   => to_id,
        '_label' => label 
      }.merge( properties )
   
      resp = Typhoeus.post( url + "/edges/#{id}", {params: params} )
      Edge.from_hash( self, handle_response(resp) )
    end

    def remove_edge( gid )
      resp = Typhoeus.delete( url + "/edges/#{gid}" )
      handle_response( resp )
      nil
    end

    def get_edge( gid )
      resp = Typhoeus.get( url + "/edges/#{gid}" )
      Edge.from_hash( self, handle_response(resp) )
    end

    def get_edges( key, value )
      params = { key: key, value: value }

      resp = Typhoeus.get( url + "/edges", params: params )
      handle_response( resp ).map do |e|
        Edge.from_hash( self, e )
      end
    end

    def edges
      resp = Typhoeus.get( url + "/edges" )
      res  = handle_response( resp )
      res.map do |res|
        Edge.from_hash( self, res )
      end
    end

    private

    def validate
      resp = Typhoeus.get( @base_url)
      res  = handle_response( resp )

      unless res.graphs.include?( @name.to_s )
        raise UnknownGraphError, "Unable to locate graph named `#{@name}"
      end
    end

    def hydrate( res )
      res.map do |r|
        type = r.delete( '_type' )
        Object.const_get( "Wewoo::#{type.capitalize}" ).from_hash( self, r )
      end
    end
  end
end
