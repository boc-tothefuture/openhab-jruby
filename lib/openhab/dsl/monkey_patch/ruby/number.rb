# frozen_string_literal: true

module OpenHAB
  module DSL
    module MonkeyPatch
      module Ruby
        #
        # Extend integer to create duration object
        #
        module IntegerExtensions
          #
          # Create Duration with the specified unit
          #
          # @return [java.time.Duration] Duration with number of units from self
          #
          %w[millis seconds minutes hours].each do |unit|
            define_method(unit) { java.time.Duration.public_send("of_#{unit}", self) }
          end

          alias_method :second, :seconds
          alias_method :millisecond, :millis
          alias_method :milliseconds, :millis
          alias_method :ms, :millis
          alias_method :minute, :minutes
          alias_method :hour, :hours
        end

        #
        # Extend float to create duration object
        #
        module FloatExtensions
          #
          # Create Duration with number of milliseconds
          #
          # @return [java.time.Duration] Duration truncated to an integral number of milliseconds from self
          #
          def millis
            java.time.Duration.of_millis(to_i)
          end

          #
          # Create Duration with number of seconds
          #
          # @return [java.time.Duration] Duration with number of seconds from self
          #
          def seconds
            (self * 1000).millis
          end

          #
          # Create Duration with number of minutes
          #
          # @return [java.time.Duration] Duration with number of minutes from self
          #
          def minutes
            (self * 60).seconds
          end

          #
          # Create Duration with number of hours
          #
          # @return [java.time.Duration] Duration with number of hours from self
          #
          def hours
            (self * 60).minutes
          end

          alias_method :second, :seconds
          alias_method :millisecond, :millis
          alias_method :milliseconds, :millis
          alias_method :ms, :millis
          alias_method :minute, :minutes
          alias_method :hour, :hours
        end

        #
        # Extend numeric to create quantity object
        #
        module NumericExtensions
          #
          # Convert Numeric to a QuantityType
          #
          # @param [Object] other String or Unit representing an OpenHAB Unit
          #
          # @return [Types::QuantityType] +self+ as a {Types::QuantityType} of the supplied Unit
          #
          def |(other)
            other = org.openhab.core.types.util.UnitUtils.parse_unit(other.to_str) if other.respond_to?(:to_str)

            return super unless other.is_a?(javax.measure.Unit)

            Types::QuantityType.new(to_d.to_java, other)
          end
        end
      end
    end
  end
end

Integer.prepend(OpenHAB::DSL::MonkeyPatch::Ruby::IntegerExtensions)
Float.prepend(OpenHAB::DSL::MonkeyPatch::Ruby::FloatExtensions)
Numeric.include(OpenHAB::DSL::MonkeyPatch::Ruby::NumericExtensions)
# Integer already has #|, so we have to prepend it here
Integer.prepend(OpenHAB::DSL::MonkeyPatch::Ruby::NumericExtensions)
