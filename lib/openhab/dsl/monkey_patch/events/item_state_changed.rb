# frozen_string_literal: true

require 'java'

module OpenHAB
  module DSL
    module MonkeyPatch
      #
      # Patches OpenHAB events
      #
      module Events
        java_import Java::OrgOpenhabCoreItemsEvents::ItemStateChangedEvent

        #
        # MonkeyPatch with ruby style accessors
        #
        class ItemStateChangedEvent
          #
          # Get the item that caused the state change
          #
          # @return [Item] Item that caused state change
          #
          def item
            # rubocop:disable Style/GlobalVars
            $ir.get(item_name)
            # rubocop:enable Style/GlobalVars
          end

          alias state item_state
          alias last old_item_state
        end
      end
    end
  end
end
