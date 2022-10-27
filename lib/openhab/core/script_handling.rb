# frozen_string_literal: true

require "openhab/log/logger"

# OpenHAB main module
module OpenHAB
  module Core
    #
    # Provide callback mechanisms for script handling
    #
    module ScriptHandling
      module_function

      # Add a callback to be run when the script has been fully loaded
      def script_loaded(&block)
        ScriptHandlingCallbacks.script_loaded_hooks << block
      end

      # Add a callback to be run when the script is unloaded
      def script_unloaded(&block)
        ScriptHandlingCallbacks.script_unloaded_hooks << block
      end
    end

    #
    # Manages script loading and unloading
    #
    module ScriptHandlingCallbacks
      include OpenHAB::Log

      class << self
        #
        # Return script_loaded_hooks
        #
        # @!visibility private
        def script_loaded_hooks
          @script_loaded_hooks ||= []
        end

        #
        # Return script_unloaded_hooks
        #
        # @!visibility private
        def script_unloaded_hooks
          @script_unloaded_hooks ||= []
        end
      end

      #
      # Executed when OpenHAB unloads a script file
      #
      # @!visibility private
      def scriptUnloaded # rubocop:disable Naming/MethodName method name dictated by OpenHAB
        logger.trace("Script unloaded")
        ScriptHandlingCallbacks.script_unloaded_hooks.each do |hook|
          hook.call
        rescue => e
          logger.error("Failed to call script_unloaded hook #{hook}: #{e}")
        end
      end

      #
      # Executed when OpenHAB loads a script file
      #
      # @!visibility private
      def scriptLoaded(filename) # rubocop:disable Naming/MethodName method name dictated by OpenHAB
        logger.trace("Script loaded: #{filename}")
        ScriptHandlingCallbacks.script_loaded_hooks.each do |hook|
          hook.call
        rescue => e
          logger.error("Failed to call script_loaded hook #{hook}: #{e}")
        end
      end
    end
  end
end
