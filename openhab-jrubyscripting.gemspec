# frozen_string_literal: true

require_relative "lib/openhab/version"

Gem::Specification.new do |spec|
  spec.name          = "openhab-jrubyscripting"
  spec.version       = OpenHAB::VERSION
  spec.authors       = ["Cody Cutrer"]
  spec.email         = ["cody@cutrer.us"]

  spec.summary       = "JRuby Helper Libraries for OpenHAB Scripting"
  spec.description   = "JRuby Helper Libraries for OpenHAB Scripting"
  spec.homepage      = "https://github.com/ccutrer/openhab-jrubyscripting"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.6.0")

  #  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://myspec.add_development_dependencyserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/ccutrer/openhab-jrubyscripting"
  spec.metadata["changelog_uri"] = "https://github.com/ccutrer/openhab-jrubyscripting/blob/main/CHANGELOG.md"

  spec.add_runtime_dependency "bundler", "~> 2.2"
  spec.add_runtime_dependency "marcel", "~> 1.0"
  spec.add_runtime_dependency "method_source", "~> 1.0"

  spec.add_development_dependency "cucumber"
  spec.add_development_dependency "cuke_linter", "~> 1.2"
  spec.add_development_dependency "guard-rubocop"
  spec.add_development_dependency "guard-shell"
  spec.add_development_dependency "guard-yard"
  spec.add_development_dependency "httparty"
  spec.add_development_dependency "irb", "~> 1.4"
  spec.add_development_dependency "persistent_httparty"
  spec.add_development_dependency "process_exists"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3.11"
  # spec.add_development_dependency 'rspec-openhab-scripting', '~> 1.1'
  spec.add_development_dependency "rubocop", "~> 1.8"
  spec.add_development_dependency "rubocop-performance", "~> 1.11"
  spec.add_development_dependency "rubocop-rake", "~> 0.6"
  spec.add_development_dependency "rubocop-rspec", "~> 2.11"
  spec.add_development_dependency "solargraph"
  spec.add_development_dependency "tty-command"
  spec.add_development_dependency "yaml-lint"
  spec.add_development_dependency "yard"

  # Specify which files should be added to the spec.add_development_dependency when it is released.
  # The `git ls-files -z` loads the files in the Rubyspec.add_development_dependency that have been added into git.
  # spec.files = Dir.chdir(File.expand_path(__dir__)) do
  #  `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|bundle)/}) }
  # end
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").select { |f| f.match(%r{^(lib)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.metadata["rubyspec.add_development_dependencys_mfa_required"] = "true"
  spec.metadata["rubygems_mfa_required"] = "true"
end
