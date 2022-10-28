# frozen_string_literal: true

module OpenHAB
  module Core
    # @!visibility private
    module Actions
      java_import org.openhab.core.automation.module.script.internal.defaultscope.ScriptThingActionsImpl

      class ScriptThingActionsImpl
        field_reader :THING_ACTIONS_MAP

        #
        # Fetch keys for all actions defined in OpenHAB
        #
        # @return [Set] of keys for defined actions in the form of 'scope-thing_uid'
        #
        def action_keys
          self.class.THING_ACTIONS_MAP.keys
        end
      end
    end
  end
end
