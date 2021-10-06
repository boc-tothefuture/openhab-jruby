# frozen_string_literal: true

require 'java'

module OpenHAB
  module DSL
    module MonkeyPatch
      #
      # Patches OpenHAB types
      #
      module Types
        java_import Java::OrgOpenhabCoreLibraryTypes::DecimalType
        java_import org.openhab.core.types.util.UnitUtils

        #
        # MonkeyPatching Decimal Type
        #
        class DecimalType
          extend Forwardable

          delegate %i[to_d zero?] => :to_big_decimal
          delegate %i[positive? negative?] => :to_d

          #
          # @param [Object] other object to compare to
          #
          # @return [Integer] -1,0,1 or nil depending on value supplied,
          #   nil comparison to supplied object is not possible.
          #
          def <=>(other)
            logger.trace("#{self.class} #{self} <=> #{other} (#{other.class})")
            case other
            when Numeric
              to_big_decimal.compare_to(other.to_d)
            when Java::OrgOpenhabCoreTypes::UnDefType
              1
            else
              other = other.state if other.respond_to? :state
              compare_to(other)
            end
          end

          #
          # Coerce objects into a DecimalType
          #
          # @param [Object] other object to coerce to a DecimalType if possible
          #
          # @return [Object] Numeric when applicable
          #
          def coerce(other)
            logger.trace("Coercing #{self} as a request from #{other.class}")
            case other
            when Numeric
              [other.to_d, to_big_decimal]
            else
              [other, self]
            end
          end

          #
          # Compare self to other through the spaceship operator
          # Compare self to other using Java BigDecimal compare method
          #
          # @param [Object] other object to compare to
          #
          # @return [Boolean] True if have the same BigDecimal representation, false otherwise
          #
          def ==(other)
            logger.trace("#{self.class} #{self} == #{other} (#{other.class})")
            (self <=> other).zero?
          end

          #
          # Convert DecimalType to a Quantity
          #
          # @param [Object] other String or Unit representing an OpenHAB Unit
          #
          # @return [OpenHAB::Core::DSL::Types::Quantity] NumberItem converted to supplied Unit
          #
          def |(other)
            other = UnitUtils.parse_unit(other) if other.is_a? String
            Quantity.new(QuantityType.new(to_big_decimal, other))
          end

          #
          # Provide details about DecimalType object
          #
          # @return [String] Representing details about the DecimalType object
          #
          def inspect
            to_string
          end
        end
      end
    end
  end
end
