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
  #       space = confluence.get_space('foo')
  #       if space
  #         puts "found space: #{space.inspect}"
  #       else
  #         space = confluence.add_space( 'foo', 'space name', 'space description' )
  #         if space
  #           puts "created space: #{space.inspect}"
  #         else
  #           puts "unable to create space: #{c.error}"
  #         end
  #       end
  #       
  #       if confluence.remove_space('foo')
  #         puts 'removed space'
  #       else
  #         puts "unable to remove space: #{c.error}"
  #       end
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

    # Create Confluence space.  Returns space or nil.
    #
    # Params:
    # +key+:: Key for space.
    # +name+:: Name of space.
    # +description+:: Description for space.
    def add_space(key, name, description)
      space = addSpace( { 'key' => key, 'name' => name, 'description' => description } )
      return space if ok?
      nil 
    end

    # Was there an error on the last request?
    def error?
      !ok?
    end

    # Return Confluence space or nil.
    #
    # Params:
    # +key+:: Confluence key for space.
    def get_space(key)
      space = getSpace(key)
      return space if ok?
      nil
    end

    # Login to the Confluence XML/RPC API.
    def login(user, password)
      raise ArgumentError if user.nil? || password.nil?
      @user, @password = user, password
      begin
        @token  = @confluence.login(@user, @password)
        @error  = nil
      rescue XMLRPC::FaultException => e
        @error = tidy_exception( e.faultString )
      rescue => e
        @error = tidy_exception( e.message )
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
        @error = tidy_exception( e.faultString )
      rescue Exception => e
        @error = tidy_exception( e.message )
      end
      return ok?
    end

    # Was the last request successful?
    def ok?
      @error.nil?
    end

    # Remove Confluence space.  Returns boolean.
    #
    # Params:
    # +key+:: Confluence key for space to remove.
    def remove_space(key)
      return removeSpace(key)
    end

    # Make the Confluence exceptions more readable.
    #
    # Params:
    # +txt+:: Exception text to clean up.
    def tidy_exception(txt)
      txt.gsub!( /^java.lang.Exception: com.atlassian.confluence.rpc.RemoteException:\s+/, '' )
    end

  end # class Client
end # module Confluence

