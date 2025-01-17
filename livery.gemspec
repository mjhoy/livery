
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "livery/version"

Gem::Specification.new do |spec|
  spec.name          = "livery"
  spec.version       = Livery::VERSION
  spec.authors       = ["Michael Hoy", "Kevin Mannix", "John Russell"]
  spec.email         = ["dev@getfreebird.com"]

  spec.summary       = %q{A library for presenter objects for use in Rails.}
  spec.description   = %q{A library for presenter objects for use in Rails.}
  spec.homepage      = "https://www.getfreebird.com"
  spec.license       = "MIT"

  spec.required_ruby_version = ">= 2.5.0"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test/|spec/|features/|.ruby-version)}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "appraisal"

  spec.add_dependency "activesupport", ">= 5.1"
  spec.add_dependency "i18n", ">= 0.7", "< 2"
end
