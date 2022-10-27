# frozen_string_literal: true

require "rubygems"
require "bundler"

Bundler.require

# it's useless with so many java objects
IRB.conf[:USE_AUTOCOMPLETE] = false

# clean any external OPENHAB or KARAF references; we want to use our private install
ENV.delete_if { |k| k.match?(/^(?:OPENHAB|KARAF)_/) }
ENV["OPENHAB_HOME"] = "#{Dir.pwd}/tmp/openhab"

require "openhab/rspec/configuration"
OpenHAB::RSpec::Configuration.use_root_instance = true
require "openhab/rspec"
