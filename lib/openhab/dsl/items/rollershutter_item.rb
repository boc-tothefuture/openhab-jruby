# frozen_string_literal: true

require 'forwardable'
require 'java'
require 'openhab/dsl/items/item_command'

module OpenHAB
  module DSL
    module Items
      #
      # Delegator to OpenHAB Rollershutter Item
      #
      class RollershutterItem < Numeric
        extend Forwardable
        extend OpenHAB::DSL::Items::ItemCommand
        include Comparable

        def_delegator :@rollershutter_item, :to_s

        java_import Java::OrgOpenhabCoreLibraryTypes::PercentType
        java_import Java::OrgOpenhabCoreLibraryTypes::UpDownType
        java_import Java::OrgOpenhabCoreLibraryTypes::StopMoveType

        item_command Java::OrgOpenhabCoreLibraryTypes::StopMoveType
        item_command Java::OrgOpenhabCoreLibraryTypes::UpDownType
        item_state   Java::OrgOpenhabCoreLibraryTypes::UpDownType

        #
        # Creates a new RollershutterItem
        #
        # @param [Java::OrgOpenhabCoreLibraryItems::RollershutterItem] rollershutter_item
        #   The OpenHAB RollershutterItem to delegate to
        #
        def initialize(rollershutter_item)
          logger.trace("Wrapping #{rollershutter_item}")
          @rollershutter_item = rollershutter_item

          super()
        end

        #
        # Returns the rollershutter's position
        #
        # @return [Java::OrgOpenhabCoreLibraryTypes::PercentType] the position of the rollershutter
        #
        def position
          state.as(PercentType)
        end

        #
        # Compare the rollershutter's position against another object
        #
        # @param [Object] other object to compare against
        #
        # @return [Integer] -1, 0 or 1 depending on the result of the comparison
        #
        def <=>(other)
          case other
          when PercentType, Java::OrgOpenhabCoreLibraryTypes::DecimalType then position.compare_to(other)
          when Numeric then position.int_value <=> other
          when RollershutterItem then position.compare_to(other.position)
          when UpDownType then state.as(UpDownType) == other
          end
        end

        #
        # Coerce self into other to enable calculations
        #
        # @param [Numeric] other Other numeric to coerce into
        #
        # @return [Array<Numeric>] an array of other and self coerced into other's type
        #
        def coerce(other)
          raise ArgumentError, "Cannot coerce to #{other.class}" unless other.is_a? Numeric

          case other
          when Integer then [other, position.int_value]
          when Float then [other, position.float_value]
          end
        end

        #
        # Case equality
        #
        # @param [Java::OrgOpenhabCoreLibraryTypes::UpDownType, Numeric] other Other object to compare against
        #
        # @return [Boolean] true if self can be defined as other, false otherwise
        #
        def ===(other)
          super unless other.is_a? UpDownType

          state.as(UpDownType).equals(other)
        end

        #
        # Define math operations
        #
        %i[+ - * / %].each do |operator|
          define_method(operator) do |other|
            right, left = coerce(other)
            left.send(operator, right)
          end
        end

        #
        # Checks if this method responds to the missing method
        #
        # @param [String] meth Name of the method to check
        # @param [Boolean] _include_private boolean if private methods should be checked
        #
        # @return [Boolean] true if this object will respond to the supplied method, false otherwise
        #
        def respond_to_missing?(meth, _include_private = false)
          @rollershutter_item.respond_to?(meth) || position.respond_to?(meth)
        end

        #
        # Forward missing methods to Openhab RollershutterItem or the PercentType representing it's state
        #   if they are defined
        #
        # @param [String] meth method name
        # @param [Array] args arguments for method
        # @param [Proc] block <description>
        #
        # @return [Object] Value from delegated method in OpenHAB NumberItem
        #
        def method_missing(meth, *args, &block)
          if @rollershutter_item.respond_to?(meth)
            @rollershutter_item.__send__(meth, *args, &block)
          elsif position.respond_to?(meth)
            position.__send__(meth, *args, &block)
          else
            raise NoMethodError, "No method `#{meth}' defined for #{self.class}"
          end
        end
      end
    end
  end
end
