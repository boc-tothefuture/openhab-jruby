# frozen_string_literal: true

module OpenHAB
  module Core
    #
    # Provide callback mechanisms for script handling
    #
    module ScriptHandling
      module_function

      #
      # Add a block of code to be executed once the rule script has finished loading.
      #
      # This can occur on OpenHAB start up, when the script is first created, or updated.
      #
      # Multiple hooks can be added by calling {#script_loaded} multiple times.
      # They can be used to perform final initializations.
      #
      # @return [void]
      #
      # @example
      #   script_loaded do
      #     logger.info 'Hi, this script has just finished loading'
      #   end
      #
      # @example
      #   script_loaded do
      #     logger.info 'I will be called after the script finished loading too'
      #   end
      #
      def script_loaded(&block)
        Core::ScriptHandlingCallbacks.script_loaded_hooks << block
      end

      #
      # Add a block of code to be executed when the script is unloaded.
      #
      # This can occur when OpenHAB shuts down, or when the script is being reloaded.
      #
      # Multiple hooks can be added by calling {#script_unloaded} multiple times.
      # They can be used to perform final cleanup.
      #
      # @return [void]
      #
      # @example
      #   script_unloaded do
      #     logger.info 'Hi, this script has been unloaded'
      #   end
      #
      def script_unloaded(&block)
        Core::ScriptHandlingCallbacks.script_unloaded_hooks << block
      end
    end

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
