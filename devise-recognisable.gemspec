
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "devise-recognisable/version"

Gem::Specification.new do |spec|
  spec.name          = "devise-recognisable"
  spec.version       = DeviseRecognisable::VERSION
  spec.authors       = ["Pixie Labs"]
  spec.email         = ["dev@pixielabs.io"]

  spec.summary       = %q{Risk-based authentication for Devise.}
  spec.homepage      = "https://github.com/pixielabs/devise-recognisable"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">=5"
  spec.add_dependency "devise"
  spec.add_dependency "jwt"
  spec.add_dependency "geocoder"
  spec.add_dependency 'damerau-levenshtein', '~> 1.1'

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
