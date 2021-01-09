require 'delegate'

module OpenHAB
  module Core
    module DSL
      module States
        java_import org.openhab.core.model.script.actions.BusEvent

        class StateStorage < SimpleDelegator
          def restore
            BusEvent.restoreStates to_h
          end

          def restore_changes
            BusEvent.restoreStates select { |item, value| item != value }
          end

          def changed?
            any? { |item, value| item != value }
          end
        end

        def store_states(*items, &block)
          items = items.flaten.map {|item| item.is_a?(Group) ? item.group : item }
          states = StateStorage.new(BusEvent.storeStates(*items).to_h)
          if block_given?
            yield
            states.restore 
          end
          return states
        end
      end
    end
  end
end
