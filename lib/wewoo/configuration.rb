module Wewoo
  class Configuration
    def self.url(value=nil)
      @url ||= begin
        url = value || ENV['TITANUP_URL'] || default_url
        url.to_s.gsub( %r(/*$), '' )
      end
    end

    private

    def self.default_url; 'http://localhost:8182'; end
  end
end
