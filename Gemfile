# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in openhab-scripting.gemspec
gemspec

group :test do
  gem 'cucumber'
  gem 'cuke_linter', '~> 1.2'
  gem 'httparty'
  gem 'persistent_httparty'
  gem 'yaml-lint'
end

group :development do
  gem 'guard-rubocop'
  gem 'guard-shell'
  gem 'guard-yard'
  gem 'jekyll', '~> 3.9.0', require: false
  gem 'just-the-docs', '~> 0.3'
  gem 'kramdown-parser-gfm'
  gem 'process_exists'
  gem 'rake', '~> 12.0'
  gem 'rubocop', '~> 1.8', require: false
  gem 'rubocop-performance', '~> 1.11', require: false
  gem 'rubocop-rake', '~> 0.6', require: false
  gem 'solargraph'
  gem 'tty-command'
  gem 'yard'
end

group :jekyll_plugins do
  gem 'jekyll-remote-theme'
end
