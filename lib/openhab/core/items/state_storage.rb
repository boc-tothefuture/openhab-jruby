# frozen_string_literal: true

require "delegate"

module OpenHAB
  module Core
    module Items
      #
      # Delegates state storage to a Hash providing methods to operate with states
      #
      class StateStorage < SimpleDelegator
        #
        # Create a StateStorage object that stores the states of the given items
        #
        # @param [Array<Item>] items A list of items
        #
        # @return [StateStorage] A state storage object
        #
        def self.from_items(*items)
          StateStorage.new(org.openhab.core.model.script.actions.BusEvent.store_states(*items).to_h)
        end

        #
        # Restore the stored states of all items
        #
        #
        def restore
          org.openhab.core.model.script.actions.BusEvent.restore_states(to_h)
        end

        #
        # Restore states for items that have changed
        #
        #
        def restore_changes
          org.openhab.core.model.script.actions.BusEvent.restore_states(select { |item, value| item != value })
        end

        #
        # Detect if any item have changed states since being stored
        #
        # @return [true,false] True if any items have changed states, false otherwise
        #
        def changed?
          any? { |item, value| item != value }
        end
      end
    end
  end
end
