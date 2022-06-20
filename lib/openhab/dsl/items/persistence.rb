# frozen_string_literal: true

module OpenHAB
  module DSL
    module Items
      #
      # Persistence extension for Items
      #
      # @note Methods that accept a timestamp can accept a ++ZonedDateTime++, Ruby ++Time++, or a ++Duration++.
      #       When given a positive Duration, the timestamp will be calculated as ++now-Duration++
      #
      module Persistence
        java_import Java::OrgOpenhabCoreTypesUtil::UnitUtils

        # A state class with an added timestamp attribute. This is used to hold OpenHAB's HistoricItem.
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
                              %i[changed_since?
                                 evolution_rate
                                 historic_state
                                 maximum_since
                                 minimum_since
                                 updated_since?]).freeze
        private_constant :QUANTITY_METHODS, :PERSISTENCE_METHODS

        # @!method persist(service = nil)
        #   Persist the state of the item
        #   @param [Symbol, String] service An optional persistence id instead of the default persistence service.
        #   @return [void]

        # @!method last_update(service = nil)
        #   Return the time the item was last updated.
        #   @param [Symbol, String] service An optional persistence id instead of the default persistence service.
        #   @return [ZonedDateTime] The timestamp of the last update

        # @!method average_since(timestamp, service = nil)
        #   Return the average value of the item's state since the given time
        #   @param [ZonedDateTime, Time, Duration] timestamp The point in time from which to search
        #   @param [Symbol, String] service An optional persistence id instead of the default persistence service.
        #   @return [DecimalType, QuantityType, nil] The average value since ++timestamp++,
        #     or nil if no previous state could be found.

        # @!method average_between(start, finish, service = nil)
        #   Return the average value of the item's state between two points in time
        #   @param [ZonedDateTime, Time, Duration] start The point in time from which to search
        #   @param [ZonedDateTime, Time, Duration] finish The point in time to which to search
        #   @param [Symbol, String] service An optional persistence id instead of the default persistence service.
        #   @return [DecimalType, QuantityType, nil] The average value between ++start++ and ++finish++,
        #     or nil if no previous state could be found.

        # @!method delta_since(timestamp, service = nil)
        #   Return the difference value of the item's state since the given time
        #   @param [ZonedDateTime, Time, Duration] timestamp The point in time from which to search
        #   @param [Symbol, String] service An optional persistence id instead of the default persistence service.
        #   @return [DecimalType, QuantityType, nil] The difference value since ++timestamp++,
        #     or nil if no previous state could be found.

        # @!method delta_between(start, finish, service = nil)
        #   Return the difference value of the item's state between two points in time
        #   @param [ZonedDateTime, Time, Duration] start The point in time from which to search
        #   @param [ZonedDateTime, Time, Duration] finish The point in time to which to search
        #   @param [Symbol, String] service An optional persistence id instead of the default persistence service.
        #   @return [DecimalType, QuantityType, nil] The difference value between ++start++ and ++finish++,
        #     or nil if no previous state could be found.

        # @!method deviation_since(timestamp, service = nil)
        #   Return the standard deviation of the item's state since the given time
        #   @param [ZonedDateTime, Time, Duration] timestamp The point in time from which to search
        #   @param [Symbol, String] service An optional persistence id instead of the default persistence service.
        #   @return [DecimalType, QuantityType, nil] The standard deviation since ++timestamp++,
        #     or nil if no previous state could be found.

        # @!method deviation_between(start, finish, service = nil)
        #   Return the standard deviation of the item's state between two points in time
        #   @param [ZonedDateTime, Time, Duration] start The point in time from which to search
        #   @param [ZonedDateTime, Time, Duration] finish The point in time to which to search
        #   @param [Symbol, String] service An optional persistence id instead of the default persistence service.
        #   @return [DecimalType, QuantityType, nil] The standard deviation between ++start++ and ++finish++,
        #     or nil if no previous state could be found.

        # @!method sum_since(timestamp, service = nil)
        #   Return the sum of the item's state since the given time
        #   @param [ZonedDateTime, Time, Duration] timestamp The point in time from which to search
        #   @param [Symbol, String] service An optional persistence id instead of the default persistence service.
        #   @return [DecimalType, QuantityType, nil] The sum since ++timestamp++,
        #     or nil if no previous state could be found.

        # @!method sum_between(start, finish, service = nil)
        #   Return the sum of the item's state between two points in time
        #   @param [ZonedDateTime, Time, Duration] start The point in time from which to search
        #   @param [ZonedDateTime, Time, Duration] finish The point in time to which to search
        #   @param [Symbol, String] service An optional persistence id instead of the default persistence service.
        #   @return [DecimalType, QuantityType, nil] The sum between ++start++ and ++finish++,
        #     or nil if no previous state could be found.

        # @!method variance_since(timestamp, service = nil)
        #   Return the variance of the item's state since the given time
        #   @param [ZonedDateTime, Time, Duration] timestamp The point in time from which to search
        #   @param [Symbol, String] service An optional persistence id instead of the default persistence service.
        #   @return [DecimalType, QuantityType, nil] The variance since ++timestamp++,
        #     or nil if no previous state could be found.

        # @!method variance_between(start, finish, service = nil)
        #   Return the variance of the item's state between two points in time
        #   @param [ZonedDateTime, Time, Duration] start The point in time from which to search
        #   @param [ZonedDateTime, Time, Duration] finish The point in time to which to search
        #   @param [Symbol, String] service An optional persistence id instead of the default persistence service.
        #   @return [DecimalType, QuantityType, nil] The variance between ++start++ and ++finish++,
        #     or nil if no previous state could be found.

        # @!method changed_since?(timestamp, service = nil)
        #   Whether the item's state has changed since the given time
        #   @param [ZonedDateTime, Time, Duration] timestamp The point in time from which to search
        #   @param [Symbol, String] service An optional persistence id instead of the default persistence service.
        #   @return [Boolean] True if the item's state has changed since the given ++timestamp++, False otherwise.

        # @!method changed_between?(start, finish, service = nil)
        #   Whether the item's state changed between two points in time
        #   @param [ZonedDateTime, Time, Duration] start The point in time from which to search
        #   @param [ZonedDateTime, Time, Duration] finish The point in time to which to search
        #   @param [Symbol, String] service An optional persistence id instead of the default persistence service.
        #   @return [Boolean] True if the item's state changed between ++start++ and ++finish++, False otherwise.

        # @!method evolution_rate(timestamp, service = nil)
        #   Return the evolution rate of the item's state since the given time
        #   @param [ZonedDateTime, Time, Duration] timestamp The point in time from which to search
        #   @param [Symbol, String] service An optional persistence id instead of the default persistence service.
        #   @return [DecimalType, QuantityType, nil] The evolution rate since ++timestamp++,
        #     or nil if no previous state could be found.

        # @!method historic_state(timestamp, service = nil)
        #   Return the the item's state at the given time
        #   @param [ZonedDateTime, Time, Duration] timestamp The point in time at which to search
        #   @param [Symbol, String] service An optional persistence id instead of the default persistence service.
        #   @return [HistoricState, nil] The item's state at ++timestamp++,
        #     or nil if no previous state could be found.

        # @!method maximum_since(timestamp, service = nil)
        #   Return the maximum value of the item's state since the given time
        #   @param [ZonedDateTime, Time, Duration] timestamp The point in time from which to search
        #   @param [Symbol, String] service An optional persistence id instead of the default persistence service.
        #   @return [HistoricState, nil] The maximum value since ++timestamp++,
        #     or nil if no previous state could be found.

        # @!method maximum_between(start, finish, service = nil)
        #   Return the maximum value of the item's state between two points in time
        #   @param [ZonedDateTime, Time, Duration] start The point in time from which to search
        #   @param [ZonedDateTime, Time, Duration] finish The point in time to which to search
        #   @param [Symbol, String] service An optional persistence id instead of the default persistence service.
        #   @return [HistoricState, nil] The maximum value between ++start++ and ++finish++,
        #     or nil if no previous state could be found.

        # @!method minimum_since(timestamp, service = nil)
        #   Return the minimum value of the item's state since the given time
        #   @param [ZonedDateTime, Time, Duration] timestamp The point in time from which to search
        #   @param [Symbol, String] service An optional persistence id instead of the default persistence service.
        #   @return [HistoricState, nil] The minimum value since ++timestamp++,
        #     or nil if no previous state could be found.

        # @!method minimum_between(start, finish, service = nil)
        #   Return the minimum value of the item's state between two points in time
        #   @param [ZonedDateTime, Time, Duration] start The point in time from which to search
        #   @param [ZonedDateTime, Time, Duration] finish The point in time to which to search
        #   @param [Symbol, String] service An optional persistence id instead of the default persistence service.
        #   @return [HistoricState, nil] The minimum value between ++start++ and ++finish++,
        #     or nil if no previous state could be found.

        # @!method updated_since?(timestamp, service = nil)
        #   Whether the item's state has been updated since the given time
        #   @param [ZonedDateTime, Time, Duration] timestamp The point in time from which to search
        #   @param [Symbol, String] service An optional persistence id instead of the default persistence service.
        #   @return [Boolean] True if the item's state has been updated since the given ++timestamp++, False otherwise.

        # @!method updated_between?(start, finish, service = nil)
        #   Whether the item's state was updated between two points in time
        #   @param [ZonedDateTime, Time, Duration] start The point in time from which to search
        #   @param [ZonedDateTime, Time, Duration] finish The point in time to which to search
        #   @param [Symbol, String] service An optional persistence id instead of the default persistence service.
        #   @return [Boolean] True if the item's state was updated between ++start++ and ++finish++, False otherwise.

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
        # @return [HistoricState, nil] the previous state or nil if no previous state could be found,
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
            result = PersistenceExtensions.public_send(method.to_s.delete_suffix('?'), self, to_zdt(timestamp),
                                                       service&.to_s)
            wrap_result(result, method)
          end

          next unless /_since\??$/.match?(method.to_s)

          between_method = method.to_s.sub('_since', '_between').to_sym
          define_method(between_method) do |start, finish, service = nil|
            service ||= persistence_service
            result = PersistenceExtensions.public_send(between_method.to_s.delete_suffix('?'), self, to_zdt(start),
                                                       to_zdt(finish), service&.to_s)
            wrap_result(result, method)
          end
        end

        alias changed_since changed_since?
        alias changed_between changed_between?
        alias updated_since updated_since?
        alias updated_between updated_between?

        private

        #
        # Convert timestamp to ZonedDateTime with duration negated to indicate a time in the past
        #
        # @param [Object] timestamp timestamp to convert
        #
        # @return [ZonedDateTime]
        #
        def to_zdt(timestamp)
          timestamp = timestamp.negated if timestamp.is_a? Java::JavaTime::Duration
          OpenHAB::DSL.to_zdt(timestamp)
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
        # Wrap the result into a more convenient object type depending on the method and result.
        #
        # @param [Object] result the raw result type to be wrapped
        # @param [Symbol] method the name of the called method
        #
        # @return [HistoricState] a {HistoricState} object if the result was a HistoricItem
        # @return [QuantityType] a ++QuantityType++ object if the result was an average, delta, deviation,
        #                        sum, or variance.
        # @return [Object] the original result object otherwise.
        #
        def wrap_result(result, method)
          java_import org.openhab.core.persistence.HistoricItem

          return HistoricState.new(quantify(result.state), result.timestamp) if result.is_a?(HistoricItem)
          return quantify(result) if QUANTITY_METHODS.include?(method)

          result
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
