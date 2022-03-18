# frozen_string_literal: true

require 'delegate'

module OpenHAB
  module DSL
    #
    # Manages storing and restoring item state
    #
    module States
      module_function

      #
      # Store states of supplied items
      #
      # @param [Array] items to store states of
      #
      # @return [StateStorage] item states
      #
      def store_states(*items)
        items = items.flatten.map do |item|
          item.respond_to?(:__getobj__) ? item.__getobj__ : item
        end
        states = OpenHAB::DSL::Support::StateStorage.from_items(*items)
        if block_given?
          yield
          states.restore
        end
        states
      end

      #
      # Check if all the given items have a state (not UNDEF or NULL)
      #
      # @param [Array] items whose state must be non-nil
      # @param [<Type>] check_things when true, also ensures that all linked things are online
      #
      # @return [Boolean] true if all the items have a state, false otherwise
      #
      def state?(*items, things: false)
        items.flatten.all? { |item| (!things || item.things.all?(&:online?)) && item.state? }
      end
    end

    module Support
      java_import org.openhab.core.model.script.actions.BusEvent
      #
      # Delegates state storage to a Hash providing methods to operate with states
      #
      class StateStorage < SimpleDelegator
        #
        # Create a StateStorage object that stores the states of the given items
        #
        # @param [Array<Item>] *items A list of items
        #
        # @return [StateStorage] A state storage object
        #
        def self.from_items(*items)
          StateStorage.new(BusEvent.storeStates(*items).to_h)
        end

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
    end
  end
end
