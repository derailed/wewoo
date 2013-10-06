# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'titanup/version'

Gem::Specification.new do |spec|
  spec.name          = "titanup"
  spec.version       = Titanup::VERSION
  spec.authors       = ["derailed"]
  spec.email         = ["fernand.galiana@gmail.com"]
  spec.description   = %q{Ruby interface to Titan graph database}
  spec.summary       = %q{Leverages Rexster to manage a graph using Ruby}
  spec.homepage      = "http://titanup.io"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.test_files    = `git ls-files -- {spec}/*`.split("\n")

  spec.add_dependency 'typhoeus'                 , '~> 0.6.2'
  spec.add_dependency 'map'                      , '~> 6.5.1'
  
  spec.add_development_dependency "bundler"      , '~> 1.3'
  spec.add_development_dependency "rake"         , '~> 10.1.0'
  spec.add_development_dependency "rspec"        , '~> 2.14.1'
  spec.add_development_dependency "simplecov"    , '~> 0.7.1'
  spec.add_development_dependency "guard"        , '~> 1.8.3'
  spec.add_development_dependency "guard-rspec"  , '~> 3.1.0'
  spec.add_development_dependency "guard-bundler", '~> 1.0.0'
  spec.add_development_dependency "fuubar"       , '~> 1.2.1'
end
