# frozen_string_literal: true

require_relative "lib/openhab/dsl/version"

Gem::Specification.new do |spec|
  spec.name          = "openhab-jrubyscripting"
  spec.version       = OpenHAB::DSL::VERSION
  spec.licenses      = ["EPL-2.0"]
  spec.authors       = ["Cody Cutrer"]
  spec.email         = ["cody@cutrer.us"]

  spec.summary       = "JRuby Helper Libraries for OpenHAB Scripting"
  spec.homepage      = "https://ccutrer.github.io/openhab-jrubyscripting/"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.6.0")

  spec.metadata = {
    "homepage_uri" => spec.homepage,
    "source_code_uri" => "https://github.com/ccutrer/openhab-jrubyscripting",
    "documentation_uri" => "https://ccutrer.github.io/openhab-jrubyscripting/",
    "changelog_uri" => "https://ccutrer.github.io/openhab-jrubyscripting/file.CHANGELOG.html",
    "rubygems_mfa_required" => "true"
  }

  spec.add_runtime_dependency "bundler", "~> 2.2"
  spec.add_runtime_dependency "marcel", "~> 1.0"
  spec.add_runtime_dependency "method_source", "~> 1.0"

  spec.add_development_dependency "cucumber", "~> 7.1"
  spec.add_development_dependency "cuke_linter", "~> 1.2"
  spec.add_development_dependency "guard-rubocop", "~> 1.5"
  spec.add_development_dependency "guard-shell", "~> 0.7"
  spec.add_development_dependency "guard-yard", "~> 2.2"
  spec.add_development_dependency "httparty", "~> 0.20"
  spec.add_development_dependency "irb", "~> 1.4"
  spec.add_development_dependency "persistent_httparty", "~> 0.1"
  spec.add_development_dependency "process_exists", "~> 0.2"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3.11"
  spec.add_development_dependency "rubocop", "~> 1.8"
  spec.add_development_dependency "rubocop-performance", "~> 1.11"
  spec.add_development_dependency "rubocop-rake", "~> 0.6"
  spec.add_development_dependency "rubocop-rspec", "~> 2.11"
  spec.add_development_dependency "timecop", "~> 0.9"
  spec.add_development_dependency "tty-command", "~> 0.10"
  spec.add_development_dependency "yaml-lint", "~> 0.0"

  spec.files = Dir["{lib}/**/*"]
  spec.require_paths = ["lib"]
end
