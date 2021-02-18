# frozen_string_literal: true

require 'java'
require 'openhab/dsl/items/item_command'

module OpenHAB
  module DSL
    module MonkeyPatch
      #
      # Patches OpenHAB items
      #
      module Items
        java_import Java::OrgOpenhabCoreLibraryItems::SwitchItem

        # Alias class names for easy is_a? comparisons
        ::Switch = SwitchItem

        #
        # Monkeypatching SwitchItem to add Ruby Support methods
        #
        class SwitchItem
          extend OpenHAB::DSL::Items::ItemCommand

          java_import Java::OrgOpenhabCoreLibraryTypes::OnOffType

          item_command Java::OrgOpenhabCoreLibraryTypes::OnOffType
          item_state Java::OrgOpenhabCoreLibraryTypes::OnOffType

          alias truthy? on?

          #
          # Send a command to invert the state of the switch
          #
          # @return [OnOffType] Inverted state
          #
          def toggle
            self << !self
          end

          #
          # Return the inverted state of the switch: ON if the switch is OFF, UNDEF or NULL; OFF if the switch is ON
          #
          # @return [OnOffType] Inverted state
          #
          def !
            return !state if state?

            OnOffType::ON
          end

          #
          # Check for equality against supplied object
          #
          # @param [Object] other object to compare to
          #
          # @return [Boolean] True if other is a OnOffType and other equals state for this switch item,
          #   otherwise result from super
          #
          def ==(other)
            if other.is_a? OnOffType
              state? && state == other
            else
              super
            end
          end
        end
      end
    end
  end
end
