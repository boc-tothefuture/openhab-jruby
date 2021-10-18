# frozen_string_literal: true

require 'delegate'

module OpenHAB
  module DSL
    #
    # Manages storing and restoring item state
    #
    module States
      java_import org.openhab.core.model.script.actions.BusEvent

      #
      # Delegates state storage to a Hash providing methods to operate with states
      #
      class StateStorage < SimpleDelegator
        #
        # Restore the stored states of all items
        #
        #
        def restore
          BusEvent.restoreStates(to_h)
        end

        #
        # Restore states for items that have changed
        #
        #
        def restore_changes
          BusEvent.restoreStates(select { |item, value| item != value })
        end

        #
        # Detect if any item have changed states since being stored
        #
        # @return [Boolean] True if any items have changed states, false otherwise
        #
        def changed?
          any? { |item, value| item != value }
        end
      end

      #
      # Store states of supplied items
      #
      # @param [Array] items to store states of
      #
      # @return [StateStorage] item states
      #
      def store_states(*items)
        items = items.flatten
        states = StateStorage.new(BusEvent.storeStates(*items).to_h)
        if block_given?
          yield
          states.restore
        end
        states
      end
    end
  end
end
