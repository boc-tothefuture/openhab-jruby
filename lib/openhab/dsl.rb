# frozen_string_literal: true

require "java"
require "openhab/core/load_path"
require "openhab/core/entity_lookup"
require "openhab/core/script_handling"
require "openhab/core/openhab_setup"
require "openhab/log/logger"
require "openhab/dsl/dsl"
require "openhab/dsl/version"

#
# Module used to extend base object with OpenHAB Library functionality
#
module OpenHAB
  include OpenHAB::Log
  #
  # Extends calling object with DSL and helper methods
  #
  # @param [Object] base Object to decorate with DSL and helper methods
  #
  def self.extended(base)
    OpenHAB::Core.wait_till_openhab_ready
    base.extend OpenHAB::Core::ScriptHandling
    base.extend OpenHAB::Core::ScriptHandlingCallbacks
    base.extend OpenHAB::Core::EntityLookup
    base.extend OpenHAB::DSL

    logger.debug "OpenHAB JRuby Scripting Library Version #{OpenHAB::DSL::VERSION} Loaded"

    OpenHAB::Core.add_rubylib_to_load_path
  end
end

# Extend caller with OpenHAB methods
extend OpenHAB # rubocop:disable Style/MixinUsage
