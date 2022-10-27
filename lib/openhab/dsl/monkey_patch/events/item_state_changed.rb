# frozen_string_literal: true

require "openhab/dsl/types/un_def_type"

module OpenHAB
  module DSL
    module MonkeyPatch
      #
      # Patches OpenHAB events
      #
      module Events
        java_import org.openhab.core.items.events.ItemStateChangedEvent

        #
        # Adds methods to core OpenHAB ItemStateChangedEvent to make it more natural in Ruby
        #
        class ItemStateChangedEvent < ItemEvent
          include ItemState

          #
          # Check if state was == UNDEF
          #
          # @return [Boolean] True if the state is UNDEF, false otherwise
          #
          def was_undef?
            old_item_state == UNDEF
          end

          #
          # Check if state was == NULL
          #
          # @return [Boolean] True if the state is NULL, false otherwise
          def was_null?
            old_item_state == NULL
          end

          #
          # Check if state was defined (not UNDEF or NULL)
          #
          # @return [Boolean] True if state is not UNDEF or NULL
          #
          def was?
            !old_item_state.is_a?(Types::UnDefType)
          end

          #
          # Get the previous item state
          #
          # @return [Types::Type] OpenHAB state if state was not UNDEF or NULL, nil otherwise
          #
          def was
            old_item_state if was?
          end
          # @deprecated
          alias_method :last, :was
        end
      end
    end
  end
end
