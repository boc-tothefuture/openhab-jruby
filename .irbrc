# frozen_string_literal: true

require 'rubygems'
require 'bundler'

Bundler.require(:default, :development, :test)

# it's useless with so many java objects
IRB.conf[:USE_AUTOCOMPLETE] = false

# clean any external OPENHAB or KARAF references; we want to use our private install
ENV.delete_if { |k| k.match?(/^(?:OPENHAB|KARAF)_/) }
ENV['OPENHAB_HOME'] = "#{Dir.pwd}/tmp/openhab"

require 'rspec/openhab/configuration'
RSpec::OpenHAB::Configuration.use_root_instance = true
require 'rspec-openhab-scripting'
