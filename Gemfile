# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in openhab-scripting.gemspec
gemspec

group :test do
  gem 'cucumber', require: false
  gem 'cuke_linter', '~> 1.2', require: false
  gem 'httparty'
  gem 'persistent_httparty'
  gem 'yaml-lint'
end

group :development do
  gem 'guard-rubocop', require: false
  gem 'guard-shell', require: false
  gem 'guard-yard', require: false
  gem 'jekyll', '~> 3.9.0', require: false
  gem 'just-the-docs', '~> 0.3', require: false
  gem 'kramdown-parser-gfm'
  gem 'process_exists'
  gem 'rake', '~> 12.0', require: false
  gem 'rubocop', '~> 1.8', require: false
  gem 'rubocop-performance', '~> 1.11', require: false
  gem 'rubocop-rake', '~> 0.6', require: false
  gem 'solargraph'
  gem 'tty-command'
  gem 'yard', require: false
end

group :jekyll_plugins do
  gem 'jekyll-remote-theme'
end
