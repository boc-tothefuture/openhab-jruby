# frozen_string_literal: true

require 'core/duration'

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
            # Create Duration with unit of seconds
            #
            # @return [OpenHAB::Core::Duration] Duration with number of seconds from self
            #
            def seconds
              Duration.new(temporal_unit: :SECONDS, amount: self)
            end

            #
            # Create Duration with unit of milliseconds
            #
            # @return [OpenHAB::Core::Duration] Duration with number of milliseconds from self
            #
            def milliseconds
              Duration.new(temporal_unit: :MILLISECONDS, amount: self)
            end

            #
            # Create Duration with unit of minutes
            #
            # @return [OpenHAB::Core::Duration] Duration with number of minutes from self
            #
            def minutes
              Duration.new(temporal_unit: :MINUTES, amount: self)
            end

            #
            # Create Duration with unit of hours
            #
            # @return [OpenHAB::Core::Duration] Duration with number of hours from self
            #
            def hours
              Duration.new(temporal_unit: :HOURS, amount: self)
            end

            alias second seconds
            alias millisecond milliseconds
            alias ms milliseconds
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
