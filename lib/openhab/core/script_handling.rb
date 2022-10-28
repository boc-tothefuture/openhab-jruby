# frozen_string_literal: true

# OpenHAB main module
module OpenHAB
  module Core
    #
    # Manages script loading and unloading
    #
    # @!visibility private
    module ScriptHandlingCallbacks
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

singleton_class.include(OpenHAB::Core::ScriptHandlingCallbacks)
