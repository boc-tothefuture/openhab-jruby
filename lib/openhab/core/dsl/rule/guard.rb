# frozen_string_literal: true

require 'core/dsl/property'
require 'core/log'

module OpenHAB
  module Core
    module DSL
      module Rule
        #
        # Guards for rules
        #
        module Guard
          include DSLProperty

          prop_array(:only_if) do |item|
            unless item.is_a?(Proc) || item.respond_to?(:truthy?)
              raise ArgumentError, "Object passed to only_if must respond_to 'truthy?'"
            end
          end

          prop_array(:not_if) do |item|
            unless item.is_a?(Proc) || item.respond_to?(:truthy?)
              raise ArgumentError, "Object passed to not_if must respond_to 'truthy?'"
            end
          end

          #
          # Guard that can prevent execute of a rule if not satisfied
          #
          class Guard
            include Logging

            #
            # Create a new Guard
            #
            # @param [Object] only_if Item or Proc to use as guard
            # @param [Object] not_if Item or Proc to use as guard
            #
            def initialize(only_if: nil, not_if: nil)
              @only_if = only_if
              @not_if = not_if
            end

            #
            # Convert the guard into a string
            #
            # @return [String] describing the only_of and not_if guards
            #
            def to_s
              "only_if: #{@only_if}, not_if: #{@not_if}"
            end

            #
            # Checks if a guard should run
            #
            # @param [OpenHAB Trigger Event] event OpenHAB Trigger Event
            #
            # @return [Boolean] True if guard is satisfied, false otherwise
            #
            def should_run?(event)
              logger.trace("Checking guards #{self}")
              check(@only_if, check_type: :only_if, event: event) && check(@not_if, check_type: :not_if, event: event)
            end

            private

            #
            # Check if guard is satisfied
            #
            # @param [Array] conditions to check
            # @param [Symbol] check_type type of check to perform (:only_if or :not_if)
            # @param [Event] event OpenHAB event to see if it satisfies the guard
            #
            # @return [Boolean] True if guard is satisfied, false otherwise
            #
            def check(conditions, check_type:, event:)
              return true if conditions.nil? || conditions.empty?

              procs, items = conditions.flatten.partition { |condition| condition.is_a? Proc }
              logger.trace("Procs: #{procs} Items: #{items}")

              items.each { |item| logger.trace("#{item} truthy? #{item.truthy?}") }

              case check_type
              when :only_if
                items.all?(&:truthy?) && procs.all? { |proc| proc.call(event) }
              when :not_if
                items.none?(&:truthy?) && procs.none? { |proc| proc.call(event) }
              else
                raise ArgumentError, "Unexpected check type: #{check_type}"
              end
            end
          end
        end
      end
    end
  end
end
