# frozen_string_literal: true

module OpenHAB
  module DSL
    module MonkeyPatch
      module Items
        #
        # Persistence extension for Items
        #
        module Persistence
          %w[persist last_update].each do |method|
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
            PersistenceExtensions.previous_state(self, skip_equal, service&.to_s)
          end

          %w[
            average_since
            changed_since
            delta_since
            deviation_since
            evolution_rate
            historic_state
            maximum_since
            minimum_since
            sum_since
            updated_since
            variance_since
          ].each do |method|
            define_method(method) do |timestamp, service = nil|
              service ||= persistence_service
              if timestamp.is_a? Java::JavaTimeTemporal::TemporalAmount
                timestamp = Java::JavaTime::ZonedDateTime.now.minus(timestamp)
              end
              PersistenceExtensions.public_send(method, self, timestamp, service&.to_s)
            end
          end

          private

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
end
