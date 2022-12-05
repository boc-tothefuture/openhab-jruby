# frozen_string_literal: true

require_relative "item_state_event"

module OpenHAB
  module Core
    module Events
      java_import org.openhab.core.items.events.ItemStateChangedEvent

      #
      # Adds methods to core openHAB ItemStateChangedEvent to make it more natural in Ruby
      #
      class ItemStateChangedEvent < ItemEvent
        include ItemState

        #
        # Check if state was == UNDEF
        #
        # @return [true,false] True if the state is UNDEF, false otherwise
        #
        def was_undef?
          old_item_state == UNDEF
        end

        #
        # Check if state was == NULL
        #
        # @return [true,false] True if the state is NULL, false otherwise
        def was_null?
          old_item_state == NULL
        end

        #
        # Check if state was defined (not UNDEF or NULL)
        #
        # @return [true,false] True if state is not UNDEF or NULL
        #
        def was?
          !old_item_state.is_a?(UnDefType)
        end

        #
        # @!attribute [r] was
        # @return [State, nil] The state of the item if it was not {UNDEF} or {NULL}, `nil` otherwise.
        #
        def was
          old_item_state if was?
        end
      end
    end
  end
end
