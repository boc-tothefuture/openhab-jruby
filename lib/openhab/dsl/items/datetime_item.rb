# frozen_string_literal: true

require 'forwardable'
require 'java'
require 'time'
require 'openhab/dsl/types/datetime'
require 'openhab/dsl/items/item_delegate'
require 'openhab/dsl/items/item_command'

module OpenHAB
  module DSL
    module Items
      #
      # Delegation to OpenHAB DateTime Item
      #
      # @author Anders Alfredsson
      #
      class DateTimeItem
        extend Forwardable
        extend OpenHAB::DSL::Items::ItemDelegate
        extend OpenHAB::DSL::Items::ItemCommand
        include Comparable

        def_item_delegator :@oh_item
        attr_reader :oh_item

        item_type Java::OrgOpenhabCoreLibraryItems::DateTimeItem

        #
        # Create a new DateTimeItem
        #
        # @param [Java::org::openhab::core::libarary::items::DateTimeItem] datetime_item Openhab DateTimeItem to
        # delegate to
        #
        def initialize(datetime_item)
          @oh_item = datetime_item
          item_missing_delegate { @oh_item }
          item_missing_delegate { to_dt }
        end

        #
        # Return an instance of DateTime that wraps the DateTimeItem's state
        #
        # @return [OpenHAB::DSL::Types::DateTime] Wrapper for the Item's state, or nil if it has no state
        #
        def to_dt
          OpenHAB::DSL::Types::DateTime.new(@oh_item.state) if state?
        end

        #
        # Compare the Item's state to another Item or object that can be compared
        #
        # @param [Object] other Other objet to compare against
        #
        # @return [Integer] -1, 0 or 1 depending on the result of the comparison
        #
        def <=>(other)
          return unless state?

          logger.trace("Comparing self (#{self.class}) to #{other} (#{other.class})")
          other = other.to_dt if other.is_a? DateTimeItem
          to_dt <=> other
        end

        #
        # Get the time zone of the Item
        #
        # @return [String] The timezone in `[+-]hh:mm(:ss)` format or nil if the Item has no state
        #
        def zone
          to_dt.zone if state?
        end
      end
    end
  end
end
