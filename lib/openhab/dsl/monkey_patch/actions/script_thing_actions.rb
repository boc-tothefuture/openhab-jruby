# frozen_string_literal: true

require 'java'

module OpenHAB
  module DSL
    module MonkeyPatch
      #
      # Patches OpenHAB actions
      #
      module Actions
        #
        # MonkeyPatching ScriptThingActions
        #
        class << $actions # rubocop:disable Style/GlobalVars
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
end
