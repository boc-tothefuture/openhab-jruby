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
        java_import Java::OrgOpenhabCoreTypes::UnDefType

        #
        # MonkeyPatch with ruby style accessors
        #
        class ItemStateChangedEvent
          include ItemStateUnDefTypeHelpers

          #
          # Check if state was == UNDEF
          #
          # @return [Boolean] True if the state is UNDEF, false otherwise
          #
          def was_undef?
            old_item_state == UnDefType::UNDEF
          end

          #
          # Check if state was == NULL
          #
          # @return [Boolean] True if the state is NULL, false otherwise
          def was_null?
            old_item_state == UnDefType::NULL
          end

          #
          # Check if state was defined (not UNDEF or NULL)
          #
          # @return [Boolean] True if state is not UNDEF or NULL
          #
          def was?
            was_undef? == false && was_null? == false
          end

          #
          # Get the previous item state
          #
          # @return [State] OpenHAB state if state was not UNDEF or NULL, nil otherwise
          #
          def was
            old_item_state if was?
          end

          alias last was
        end
      end
    end
  end
end
