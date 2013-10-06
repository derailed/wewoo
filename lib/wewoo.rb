require "wewoo/version"

module Wewoo
  LIBPATH = ::File.expand_path(::File.dirname(__FILE__)) + ::File::SEPARATOR
  PATH    = ::File.dirname(LIBPATH) + ::File::SEPARATOR  
  
  def self.configure(&block)
    Configuration.module_eval( &block )
  end

  def self.require_all_libs_relative_to( fname, dir = nil )
    dir ||= ::File.basename(fname, '.*')
    search_me = ::File.expand_path(
        ::File.join(::File.dirname(fname), dir, '**', '*.rb'))
    Dir.glob(search_me).sort.each { |rb| require rb }
  end  
end

Wewoo.require_all_libs_relative_to File.expand_path( "wewoo", Wewoo::LIBPATH )
