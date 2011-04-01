require 'xmlrpc/client'

module Confluence # :nodoc:
  # = Confluence::Client - Ruby client for the Confluence XML::RPC API.
  # 
  # == Usage
  #
  #   Confluence::Client.new(url) do |confluence|
  #     
  #     if confluence.login(user, pass)
  #       
  #       # Was last API call successful?
  #       confluence.ok?
  #
  #       # Print error message if error on last API call.
  #       puts confluence.error if confluence.error?
  #       
  #       confluence.logout
  #     end
  #
  #   end 
  class Client

    # Error message from last request (if any).
    attr_reader :error
    # Security token.
    attr_reader :token

    # Create new Confluence client.
    #
    # Params:
    # +url+:: Base URL for the Confluence XML/RPC API.  'rpc/xmlrpc' appended if not present.
    def initialize(url)
      raise ArgumentError if url.nil? || url.empty?
      url += '/rpc/xmlrpc' unless url =~ /\/rpc\/xmlrpc$/
      @server         = XMLRPC::Client.new2(url)
      @server.timeout = 305                                 # XXX 
      @confluence     = @server.proxy_async('confluence1')  # XXX

      @error          = nil
      @password       = nil
      @token          = nil
      @user           = nil

      yield self if block_given?
    end

    # Was there an error on the last request?
    def error?
      !ok?
    end

    # Login to the Confluence XML/RPC API.
    def login(user, password)
      raise ArgumentError if user.nil? || password.nil?
      @user, @password = user, password
      begin
        @token  = @confluence.login(@user, @password)
        @error  = nil
      rescue XMLRPC::FaultException => e
        @error = e.faultString
      rescue => e
        @error = e.message
      end
      return ok?
    end

    def method_missing(method_name, *args)
      unless @token
        @error = "not authenticated"
        return false
      end
      begin
        @error = nil
        return @confluence.send( method_name, *( [@token] + args ) )  
      rescue XMLRPC::FaultException => e
        @error = e.faultString
      rescue Exception => e
        @error = e.message
      end
      return ok?
    end

    # Was the last request successful?
    def ok?
      @error.nil?
    end

  end # class Client
end # module Confluence

