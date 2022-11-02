# frozen_string_literal: true

module OpenHAB
  module DSL
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
  end
end
