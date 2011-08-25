#!/usr/bin/env ruby

require 'confluence-client'

def usage
  warn "USAGE: #{ File.basename(__FILE__) } <url> <user> <password> <space key> <user_name>"
  exit(1)
end

url, user, password, space_key, user_name = ARGV
url       || usage
user      || usage
password  || usage
space_key || usage
user_name || usage

Confluence::Client.new(url) do |confluence|

  if confluence.login(user, password)
    warn confluence.getPermissionsForUser(space_key, user_name)
    raise(confluence.error) if confluence.error?

    confluence.logout
    raise(confluence.error) if confluence.error?
  else
    warn "unable to login!"
    raise(confluence.error) if confluence.error?
  end

end

