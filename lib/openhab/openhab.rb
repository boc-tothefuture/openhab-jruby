# frozen_string_literal: true

# First patch the $LOAD_PATH to include lib dir
require "#{__dir__}/core/patch_load_path.rb"

require 'core/startup_delay'
require 'core/log'
require 'core/debug'
require 'core/dsl'
require 'core/dsl/items'

module OpenHAB
  def self.extended(base)
    base.extend Logging
    base.extend Debug
    base.extend DSL
    base.extend EntityLookup
    base.extend OpenHAB::Core::DSL::Tod
    base.send :include, OpenHAB::Core::DSL::Tod
  end
end

# Extend caller with OpenHAB methods
extend OpenHAB
