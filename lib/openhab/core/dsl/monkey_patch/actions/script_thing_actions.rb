# frozen_string_literal: true

require 'java'

#
# MonkeyPatching ScriptThingActions
#
# rubocop:disable Style/ClassAndModuleChildren
class Java::OrgOpenhabCoreAutomationModuleScriptInternalDefaultscope::ScriptThingActions
  # rubocop:enable Style/ClassAndModuleChildren

  field_reader :THING_ACTIONS_MAP

  #
  # Fetch keys for all actions defined in OpenHAB
  #
  # @return [Set] of keys for defined actions in the form of 'scope-thing_uid'
  #
  def action_keys
    Java::OrgOpenhabCoreAutomationModuleScriptInternalDefaultscope::ScriptThingActions.THING_ACTIONS_MAP.keys
  end
end
