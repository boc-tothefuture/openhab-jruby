# frozen_string_literal: true

require 'openhab/log/logger'
require 'openhab/dsl/rules/rule'
require 'openhab/dsl/timers'

# OpenHAB main module
module OpenHAB
  module Core
    #
    # Manages script loading and unloading
    #
    module ScriptHandling
      include OpenHAB::Log

      #
      # Executed when OpenHAB unloads a script file
      #
      # rubocop:disable Naming/MethodName
      # method name dictacted by OpenHAB
      def scriptUnloaded
        logger.trace('Script unloaded')
        OpenHAB::DSL::Rules.cleanup_rules
        OpenHAB::DSL::Timers.cancel_all
      end
      # rubocop:enable Naming/MethodName

      #
      # Executed when OpenHAB loads a script file
      #
      # rubocop:disable Naming/MethodName
      # method name dictacted by OpenHAB
      def scriptLoaded(filename)
        logger.trace("Script loaded: #{filename}")
      end
      # rubocop:enable Naming/MethodName
    end
  end
end
