# frozen_string_literal: true

unless RUBY_ENGINE == "jruby" &&
       Gem::Version.new(RUBY_ENGINE_VERSION) >= Gem::Version.new("9.3.8.0")
  raise Gem::RubyVersionMismatch, "openhab-jrubyscripting requires JRuby 9.3.8.0 or newer"
end

require "jruby"

# we completely override some files from the DSL
$LOAD_PATH.unshift("#{__dir__}/rspec")

require "diff/lcs"

require "openhab/log"

require_relative "rspec/configuration"
require_relative "rspec/helpers"
require_relative "rspec/karaf"
require_relative "rspec/hooks"
