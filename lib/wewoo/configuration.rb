module Wewoo
  class Configuration
    def self.log_file(file=STDOUT)
      @logger ||= file
    end

    def self.debug(value=false)
      @debug ||= value
    end

    def self.url(host=nil, port=nil)
      @url = nil if host
      @url ||= begin
        url = compute_url( host, port) || ENV['WEWOO_URL'] || default_url
        url.to_s.gsub( %r(/*$), '' )
      end
    end

    private

    def self.compute_url( host, port )
      return nil unless host and port
      "http://#{host}:#{port}"
    end

    def self.default_url; compute_url( :localhost, 8182 ); end
  end
end
