# frozen_string_literal: true

# First patch the $LOAD_PATH to include lib dir
require 'openhab/core/patch_load_path'

require 'openhab/core/startup_delay'
require 'openhab/core/log'
require 'openhab/core/debug'
require 'openhab/core/dsl'

require 'openhab/version'

#
# Module used to extend base object with OpenHAB Library functionality
#
module OpenHAB
  include Logging
  #
  # Extends calling object with DSL and helper methods
  #
  # @param [Object] base Object to decorate with DSL and helper methods
  #
  #
  def self.extended(base)
    base.extend Logging
    base.extend Debug
    base.extend EntityLookup
    base.extend OpenHAB::Core::DSL
    base.extend OpenHAB::Core::DSL::Tod

    base.send :include, OpenHAB::Core::DSL::Tod
    base.send :include, OpenHAB::Core::DSL::Items
    base.send :include, OpenHAB::Core::DSL::Types
    logger.info "OpenHAB JRuby Scripting Library Version #{OpenHAB::VERSION} Loaded"
  end
end

# Extend caller with OpenHAB methods
extend OpenHAB
