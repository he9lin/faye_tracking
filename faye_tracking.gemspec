# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'faye_tracking/version'

Gem::Specification.new do |spec|
  spec.name          = "faye_tracking"
  spec.version       = FayeTracking::VERSION
  spec.authors       = ["Lin He"]
  spec.email         = ["he9lin@gmail.com"]
  spec.summary       = %q{Faye extension for tracking user subscriptions}
  spec.description   = %q{Faye extension for tracking user subscriptions, i.e. can be used for checking if a user is online.}
  spec.homepage      = "https://github.com/he9lin/faye_tracking"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "redis", "~> 3.0"

  spec.add_development_dependency "redis-namespace", "~> 1.5"
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
