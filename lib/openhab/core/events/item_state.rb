# frozen_string_literal: true

module OpenHAB
  module Core
    module Events
      java_import org.openhab.core.items.events.ItemStateEvent

      # Helpers common to ItemStateEvent and ItemStateChangedEvent
      module ItemState
        #
        # Check if the state == UNDEF
        #
        # @return [true,false] True if the state is UNDEF, false otherwise
        #
        def undef?
          item_state == UNDEF
        end

        #
        # Check if the state == NULL
        #
        # @return [true,false] True if the state is NULL, false otherwise
        def null?
          item_state == NULL
        end

        #
        # Check if the state is defined (not UNDEF or NULL)
        #
        # @return [true,false] True if state is not UNDEF or NULL
        #
        def state?
          !item_state.is_a?(UnDefType)
        end

        #
        # Get the item state
        #
        # @return [Types::PrimitiveState] OpenHAB state if state is not UNDEF or NULL, nil otherwise
        #
        def state
          item_state if state?
        end
      end

      class ItemStateEvent < ItemEvent
        include ItemState
      end
    end
  end
end
