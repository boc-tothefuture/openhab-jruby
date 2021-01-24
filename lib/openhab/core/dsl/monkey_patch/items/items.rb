# frozen_string_literal: true

require 'java'
require 'openhab/core/log'
require 'bigdecimal'

# Monkey patch items
require 'openhab/core/dsl/monkey_patch/items/metadata'
require 'openhab/core/dsl/monkey_patch/items/contact_item'
require 'openhab/core/dsl/monkey_patch/items/dimmer_item'
require 'openhab/core/dsl/monkey_patch/items/switch_item'
require 'openhab/core/dsl/monkey_patch/items/group_item'

module OpenHAB
  module Core
    module DSL
      module MonkeyPatch
        #
        # Monkeypatches Items
        #
        module Items
          #
          # Extensions for Items
          #
          module ItemExtensions
            include Logging
            java_import org.openhab.core.model.script.actions.BusEvent
            java_import org.openhab.core.types.UnDefType

            #
            # Send a command to this item
            #
            # @param [Object] command to send to object
            #
            #
            def command(command)
              command = command.to_java.strip_trailing_zeros if command.is_a? BigDecimal
              logger.trace "Sending Command #{command} to #{id}"
              BusEvent.sendCommand(self, command.to_s)
            end

            alias << command

            #
            # Send an update to this item
            #
            # @param [Object] update the item
            #
            #
            def update(update)
              logger.trace "Sending Update #{update} to #{id}"
              BusEvent.postUpdate(self, update.to_s)
            end

            #
            # Check if the item state == UNDEF
            #
            # @return [Boolean] True if the state is UNDEF, false otherwise
            #
            def undef?
              # Need to explicitly call the super method version because this state will never return UNDEF
              method(:state).super_method.call == UnDefType::UNDEF
            end

            #
            # Check if the item state == NULL
            #
            # @return [Boolean] True if the state is NULL, false otherwise
            def null?
              # Need to explicitly call the super method version because this state will never return NULL
              method(:state).super_method.call == UnDefType::NULL
            end

            #
            # Check if the item has a state (not UNDEF or NULL)
            #
            # @return [Boolean] True if state is not UNDEF or NULL
            #
            def state?
              undef? == false && null? == false
            end

            #
            # Get the item state
            #
            # @return [State] OpenHAB item state if state is not UNDEF or NULL, nil otherwise
            #
            def state
              super if state?
            end

            #
            # Get an ID for the item, using the item label if set, otherwise item name
            #
            # @return [String] label if set otherwise name
            #
            def id
              label || name
            end

            #
            # Get the string representation of the state of the item
            #
            # @return [String] State of the item as a string if not UNDEF or NULL, nil otherwise
            #
            def to_s
              state&.to_s
            end

            #
            # Inspect the item
            #
            # @return [String] details of the item
            #
            def inspect
              toString
            end
          end
        end
      end
    end
  end
end

# rubocop:disable Style/ClassAndModuleChildren
class Java::OrgOpenhabCoreItems::GenericItem
  # rubocop:enable Style/ClassAndModuleChildren
  prepend OpenHAB::Core::DSL::MonkeyPatch::Items::ItemExtensions
  prepend OpenHAB::Core::DSL::MonkeyPatch::Items::Metadata
end
