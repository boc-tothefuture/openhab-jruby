# frozen_string_literal: true

require 'java'

module OpenHAB
  module DSL
    module MonkeyPatch
      #
      # Patches OpenHAB events
      #
      module Events
        java_import Java::OrgOpenhabCoreItemsEvents::ItemStateEvent
        java_import Java::OrgOpenhabCoreTypes::UnDefType

        # Helpers common to ItemStateEvent and ItemStateChangedEvent
        module ItemStateUnDefTypeHelpers
          #
          # Check if the state == UNDEF
          #
          # @return [Boolean] True if the state is UNDEF, false otherwise
          #
          def undef?
            item_state == UnDefType::UNDEF
          end

          #
          # Check if the state == NULL
          #
          # @return [Boolean] True if the state is NULL, false otherwise
          def null?
            item_state == UnDefType::NULL
          end

          #
          # Check if the state is defined (not UNDEF or NULL)
          #
          # @return [Boolean] True if state is not UNDEF or NULL
          #
          def state?
            undef? == false && null? == false
          end

          #
          # Get the item state
          #
          # @return [State] OpenHAB state if state is not UNDEF or NULL, nil otherwise
          #
          def state
            item_state if state?
          end
        end

        #
        # MonkeyPatch with ruby style accessors
        #
        class ItemStateEvent
          include ItemStateUnDefTypeHelpers
        end
      end
    end
  end
end
