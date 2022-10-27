# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in openhab-scripting.gemspec
gemspec

group :test do
  gem "cucumber", require: false
  gem "cuke_linter", "~> 1.2", require: false
  gem "httparty"
  gem "persistent_httparty"
  gem "rspec", "~> 3.11", require: false
  # gem 'rspec-openhab-scripting', '~> 1.1', require: false
  gem "yaml-lint", require: false
end

group :development do
  gem "guard-rubocop", require: false
  gem "guard-shell", require: false
  gem "guard-yard", require: false
  gem "irb", "~> 1.4", require: false
  gem "process_exists"
  gem "rake", "~> 12.0", require: false
  gem "rubocop", "~> 1.8", require: false
  gem "rubocop-performance", "~> 1.11", require: false
  gem "rubocop-rake", "~> 0.6", require: false
  gem "rubocop-rspec", "~> 2.11", require: false
  gem "solargraph"
  gem "tty-command"
  gem "yard", require: false
end
