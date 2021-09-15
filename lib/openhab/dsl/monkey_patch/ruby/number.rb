# frozen_string_literal: true

module OpenHAB
  module DSL
    module MonkeyPatch
      module Ruby
        #
        # Extend integer to create duration object
        #
        module IntegerExtensions
          include OpenHAB::Core

          #
          # Create Duration with the specified unit
          #
          # @return [Java::JavaTime::Duration] Duration with number of units from self
          #
          %w[millis seconds minutes hours].each do |unit|
            define_method(unit) { Java::JavaTime::Duration.public_send("of_#{unit}", self) }
          end

          alias second seconds
          alias millisecond millis
          alias milliseconds millis
          alias ms millis
          alias minute minutes
          alias hour hours
        end

        #
        # Extend float to create duration object
        #
        module FloatExtensions
          #
          # Create Duration with number of milliseconds
          #
          # @return [Java::JavaTime::Duration] Duration truncated to an integral number of milliseconds from self
          #
          def millis
            Java::JavaTime::Duration.of_millis(to_i)
          end

          #
          # Create Duration with number of seconds
          #
          # @return [Java::JavaTime::Duration] Duration with number of seconds from self
          #
          def seconds
            (self * 1000).millis
          end

          #
          # Create Duration with number of minutes
          #
          # @return [Java::JavaTime::Duration] Duration with number of minutes from self
          #
          def minutes
            (self * 60).seconds
          end

          #
          # Create Duration with number of hours
          #
          # @return [Java::JavaTime::Duration] Duration with number of hours from self
          #
          def hours
            (self * 60).minutes
          end

          alias second seconds
          alias millisecond millis
          alias milliseconds millis
          alias ms millis
          alias minute minutes
          alias hour hours
        end
      end
    end
  end
end

Integer.prepend(OpenHAB::DSL::MonkeyPatch::Ruby::IntegerExtensions)
Float.prepend(OpenHAB::DSL::MonkeyPatch::Ruby::FloatExtensions)
