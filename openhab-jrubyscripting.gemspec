# frozen_string_literal: true

require_relative 'lib/openhab/version'

Gem::Specification.new do |spec|
  spec.name          = 'openhab-jrubyscripting'
  spec.version       = OpenHAB::VERSION
  spec.authors       = ["Cody Cutrer"]
  spec.email         = ['cody@cutrer.us']

  spec.summary       = 'JRuby Helper Libraries for OpenHAB Scripting'
  spec.description   = 'JRuby Helper Libraries for OpenHAB Scripting'
  spec.homepage      = 'https://boc-tothefuture.github.io/openhab-jruby/'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.6.0')

  #  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/ccutrer/openhab-jrubyscripting'
  spec.metadata['changelog_uri'] = 'https://github.com/ccutrer/openhab-jrubyscripting/blob/main/CHANGELOG.md'

  spec.add_runtime_dependency 'bundler', '~> 2.2'
  spec.add_runtime_dependency 'marcel', '~> 1.0'
  spec.add_runtime_dependency 'method_source', '~> 1.0'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  # spec.files = Dir.chdir(File.expand_path(__dir__)) do
  #  `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|bundle)/}) }
  # end
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").select { |f| f.match(%r{^(lib)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
end
