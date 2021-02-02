# frozen_string_literal: true

module OpenHAB
  module Core
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
        end
      end
    end
  end
end

#
# Prepend Integer class with duration extensions
#
class Integer
  prepend OpenHAB::Core::DSL::MonkeyPatch::Ruby::IntegerExtensions
end
