require 'xmlrpc/client'

module Confluence # :nodoc:
  # = Ruby client for the Confluence XML::RPC API.
  # 
  # == Usage
  #
  #   Confluence::Client.new(url) do |confluence|
  #     
  #     # Login
  #     confluence.login(user, pass)
  #     
  #   end 
  class Client

    def initialize(url)
      raise ArgumentError if url.nil? || url.empty?
      @server         = XMLRPC::Client.new2(url)
      @server.timeout = 305                                 # XXX 
      @confluence     = @server.proxy_async('confluence1')  # XXX

      @password       = nil
      @token          = nil
      @user           = nil

      yield self if block_given?
    end

    def login(user, password)
      raise ArgumentError if user.nil? || password.nil?
      @user, @password = user, password
      begin
        @token = @confluence.login(@user, @password)
      rescue XMLRPC::FaultException => e
        raise e.faultString
      end
    end

  end # class Client
end # module Confluence

