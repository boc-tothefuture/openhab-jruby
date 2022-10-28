# frozen_string_literal: true

module OpenHAB
  module Core
    # @!visibility private
    module Actions
      begin
        # openHAB 3.3 uses ScriptThingActionsImpl
        java_import Java::OrgOpenhabCoreAutomationModuleScriptInternalDefaultscope::ScriptThingActionsImpl
      rescue NameError
        # openHAB 3.2 uses ScriptThingActions
        java_import Java::OrgOpenhabCoreAutomationModuleScriptInternalDefaultscope::ScriptThingActions
        ScriptThingActionsImpl = ScriptThingActions
      end

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
