# frozen_string_literal: true

require 'java'
require 'openhab/core/log'
require 'bigdecimal'

# Monkey patch items
require 'openhab/core/dsl/monkey_patch/items/contact_item'
require 'openhab/core/dsl/monkey_patch/items/dimmer_item'
require 'openhab/core/dsl/monkey_patch/items/switch_item'
require 'openhab/core/dsl/monkey_patch/items/group_item'

module OpenHAB
  module Core
    module DSL
      module MonkeyPatch
        module Items
          module ItemExtensions
            include Logging
            java_import org.openhab.core.model.script.actions.BusEvent
            java_import org.openhab.core.types.UnDefType

            def command(command)
              command = command.to_java.strip_trailing_zeros if command.is_a? BigDecimal
              logger.trace "Sending Command #{command} to #{id}"
              BusEvent.sendCommand(self, command.to_s)
            end

            def <<(command)
              command(command)
            end

            def undef?
              # Need to explicitly call the super method version because this state will never return UNDEF
              method(:state).super_method.call == UnDefType::UNDEF
            end

            def null?
              # Need to explicitly call the super method version because this state will never return NULL
              method(:state).super_method.call == UnDefType::NULL
            end

            def state?
              undef? == false && null? == false
            end

            def state
              super if state?
            end

            def id
              label || name
            end

            def to_s
              state&.to_s
            end

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
end
