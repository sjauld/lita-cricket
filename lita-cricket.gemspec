Gem::Specification.new do |spec|
  spec.name          = "lita-cricket"
  spec.version       = "0.0.1"
  spec.authors       = ["Stuart Auld"]
  spec.email         = ["sja@marsupialmusic.net"]
  spec.description   = "Provides live cricket scores directly in Lita"
  spec.summary       = "Live cricket scores! Such wow!"
  spec.homepage      = "https://github.com/sjauld/lita-cricket"
  spec.license       = "MIT"
  spec.metadata      = { "lita_plugin_type" => "handler" }

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "lita", ">= 4.4"
  spec.add_runtime_dependency "httparty"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "rspec", ">= 3.0.0"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "coveralls"
end
