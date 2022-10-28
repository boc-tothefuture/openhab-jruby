# frozen_string_literal: true

module OpenHAB
  module DSL
    #
    # Provide callback mechanisms for script handling
    #
    module ScriptHandling
      module_function

      # Add a callback to be run when the script has been fully loaded
      # @return [void]
      def script_loaded(&block)
        Core::ScriptHandlingCallbacks.script_loaded_hooks << block
      end

      # Add a callback to be run when the script is unloaded
      # @return [void]
      def script_unloaded(&block)
        Core::ScriptHandlingCallbacks.script_unloaded_hooks << block
      end
    end
  end
end
