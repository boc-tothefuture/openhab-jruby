# frozen_string_literal: true

require 'java'
require 'openhab/dsl/items/item_command'
require 'forwardable'

module OpenHAB
  module DSL
    module MonkeyPatch
      #
      # Patches OpenHAB items
      #
      module Items
        java_import Java::OrgOpenhabCoreLibraryItems::DimmerItem
        java_import Java::OrgOpenhabCoreItems::GenericItem

        #
        # Alias class for is_a? testing
        #
        ::Dimmer = DimmerItem

        #
        # Monkey Patch DimmerItem
        #
        class DimmerItem
          include Comparable
          java_import Java::OrgOpenhabCoreLibraryTypes::DecimalType
          java_import Java::OrgOpenhabCoreLibraryTypes::IncreaseDecreaseType

          extend Forwardable
          extend OpenHAB::DSL::Items::ItemCommand

          item_type Java::OrgOpenhabCoreLibraryItems::DimmerItem

          def_delegator :state, :to_s

          #
          # Dim the dimmer
          #
          # @param [Integer] amount to dim by
          #
          # @return [Integer] level target for dimmer
          #
          def dim(amount = 1)
            [state&.to_big_decimal&.intValue&.-(amount), 0].compact
                                                           .max
                                                           .tap { |target| command(target) }
          end

          #
          # Brighten the dimmer
          #
          # @param [Integer] amount to brighten by
          #
          # @return [Integer] level target for dimmer
          #
          def brighten(amount = 1)
            state&.to_big_decimal&.intValue&.+(amount)&.tap { |target| command(target) }
          end

          #
          # Compare DimmerItem to supplied object
          #
          # @param [Object] other object to compare to
          #
          # @return [Integer] -1,0,1 or nil depending on value supplied,
          #   nil comparison to supplied object is not possible.
          #
          def <=>(other)
            logger.trace("Comparing #{self} to #{other}")
            case other
            when GenericItem, NumberItem then state <=> other.state
            when DecimalType then state <=> other
            when Numeric then state.to_big_decimal.to_d <=> other.to_d
            else compare_to(other)
            end
          end

          #
          # Coerce objects into a DimmerItem
          #
          # @param [Object] other object to coerce to a DimmerItem if possible
          #
          # @return [Object] Numeric when applicable
          #
          def coerce(other)
            logger.trace("Coercing #{self} as a request from  #{other.class}")
            case other
            when Numeric then [other, state.to_big_decimal.to_d]
            else [other, state]
            end
          end

          #
          # Compare DimmerItem to supplied object.
          # The == operator needs to be overridden because the parent java object
          # has .equals which overrides the <=> operator above
          #
          # @param [Object] other object to compare to
          #
          # @return [Integer] true if the two objects contain the same value, false otherwise
          #
          def ==(other)
            (self <=> other).zero?
          end

          #
          # Define math operations
          #
          %i[+ - / *].each do |operator|
            define_method(operator) do |other|
              right, left = coerce(other)
              left.send(operator, right)
            end
          end

          #
          # Check if dimmer has a state and state is not zero
          #
          # @return [Boolean] True if dimmer is not NULL or UNDEF and value is not 0
          #
          def truthy?
            state? && state != DecimalType::ZERO
          end

          #
          # Value of dimmer
          #
          # @return [Integer] Value of dimmer or nil if state is UNDEF or NULL
          #
          def to_i
            state&.to_big_decimal&.intValue
          end

          alias to_int to_i
        end
      end
    end
  end
end
