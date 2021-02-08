# frozen_string_literal: true

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
          java_import Java::OrgOpenhabCoreLibraryTypes::OnOffType
          #
          # Send the OFF command to the switch
          #
          #
          def off
            command(OnOffType::OFF)
          end

          #
          # Send the OFF command to the switch
          #
          #
          def on
            command(OnOffType::ON)
          end

          #
          # Check if a switch is on
          #
          # @return [Boolean] True if the switch is on, false otherwise
          #
          def on?
            state? && state == OnOffType::ON
          end

          alias truthy? on?

          #
          # Check if a switch is off
          #
          # @return [Boolean] True if the switch is off, false otherwise
          #
          def off?
            state? && state == OnOffType::OFF
          end

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
