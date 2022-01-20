# frozen_string_literal: true

module OpenHAB
  module DSL
    module Items
      #
      # Persistence extension for Items
      #
      module Persistence
        java_import Java::OrgOpenhabCoreTypesUtil::UnitUtils

        # A wrapper for OpenHAB's HistoricItem that returns the state directly
        class HistoricState < SimpleDelegator
          attr_reader :timestamp, :state

          def initialize(state, timestamp)
            @state = state
            @timestamp = timestamp
            super(@state)
          end
        end

        # All persistence methods that could return a QuantityType
        QUANTITY_METHODS = %i[average_since
                              delta_since
                              deviation_since
                              sum_since
                              variance_since].freeze

        # All persistence methods that require a timestamp
        PERSISTENCE_METHODS = (QUANTITY_METHODS +
                              %i[changed_since
                                 evolution_rate
                                 historic_state
                                 maximum_since
                                 minimum_since
                                 updated_since]).freeze
        private_constant :QUANTITY_METHODS, :PERSISTENCE_METHODS

        %i[persist last_update].each do |method|
          define_method(method) do |service = nil|
            service ||= persistence_service
            PersistenceExtensions.public_send(method, self, service&.to_s)
          end
        end

        #
        # Return the previous state of the item
        #
        # @param skip_equal [Boolean] if true, skips equal state values and
        #        searches the first state not equal the current state
        # @param service [String] the name of the PersistenceService to use
        #
        # @return the previous state or nil if no previous state could be found,
        #         or if the default persistence service is not configured or
        #         does not refer to a valid service
        #
        def previous_state(service = nil, skip_equal: false)
          service ||= persistence_service
          result = PersistenceExtensions.previous_state(self, skip_equal, service&.to_s)
          HistoricState.new(quantify(result.state), result.timestamp)
        end

        PERSISTENCE_METHODS.each do |method|
          define_method(method) do |timestamp, service = nil|
            service ||= persistence_service
            result = PersistenceExtensions.public_send(method, self, to_zdt(timestamp), service&.to_s)
            if result.is_a? Java::OrgOpenhabCorePersistence::HistoricItem
              return HistoricState.new(quantify(result.state), result.timestamp)
            end

            QUANTITY_METHODS.include?(method) ? quantify(result) : result
          end
        end

        private

        #
        # Convert timestamp to ZonedDateTime if it's a TemporalAmount
        #
        # @param [Object] timestamp to convert
        #
        # @return [ZonedDateTime]
        #
        def to_zdt(timestamp)
          if timestamp.is_a? Java::JavaTimeTemporal::TemporalAmount
            logger.trace("Converting #{timestamp} (#{timestamp.class}) to ZonedDateTime")
            Java::JavaTime::ZonedDateTime.now.minus(timestamp)
          else
            timestamp
          end
        end

        #
        # Convert value to QuantityType if it is a DecimalType and a unit is defined
        #
        # @param [Object] value The value to convert
        #
        # @return [Object] QuantityType or the original value
        #
        def quantify(value)
          if value.is_a?(Types::DecimalType) && (item_unit = UnitUtils.parse_unit(state_description&.pattern))
            logger.trace("Unitizing #{value} with unit #{item_unit}")
            Types::QuantityType.new(value.to_big_decimal, item_unit)
          else
            value
          end
        end

        #
        # Get the specified persistence service from the current thread local variable
        #
        # @return [Object] Persistence service name as String or Symbol, or nil if not set
        #
        def persistence_service
          Thread.current.thread_variable_get(:persistence_service)
        end
      end
    end
  end
end
