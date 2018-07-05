
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "courier/tweeter/version"

Gem::Specification.new do |spec|
  spec.name          = "courier-tweeter"
  spec.version       = Courier::Tweeter::VERSION
  spec.authors       = ["Matt Moriarity"]
  spec.email         = ["matt@mattmoriarity.com"]

  spec.summary       = %q{Microservice to manage Twitter users and post tweets on their behalf}
  spec.homepage      = "https://github.com/mjm/courier-tweeter"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "sinatra"
  spec.add_dependency "omniauth"
  spec.add_dependency "omniauth-twitter"
  spec.add_dependency "twitter"
  spec.add_dependency "sequel"
  spec.add_dependency "pg"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
