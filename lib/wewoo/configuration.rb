module Wewoo
  class Configuration
    def self.debug(value=false)
      @debug ||= value
    end

    def self.url(value=nil)
      @url = nil if value
      @url ||= begin
        url = value || ENV['WEWOO_URL'] || default_url
        url.to_s.gsub( %r(/*$), '' )
      end
    end

    private

    def self.default_url; 'http://localhost:8182'; end
  end
end
