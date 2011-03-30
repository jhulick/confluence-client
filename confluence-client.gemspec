# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "confluence-client/version"

Gem::Specification.new do |s|
  s.name        = "confluence-client"
  s.version     = Confluence::Client::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Blair Christensen']
  s.email       = ['blair.christensen@gmail.com']
  s.homepage    = 'https://github.com/blairc/confluence-client'
  s.summary     = %q{Ruby client for the Confluence XML::RPC API}
  s.description = %q{Ruby client for the Confluence XML::RPC API}

  s.rubyforge_project = "confluence-client"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
