# frozen_string_literal: true

require "openhab/dsl/rules/property"

module OpenHAB
  module DSL
    module Rules
      #
      # Guards for rules
      #
      module Guard
        include OpenHAB::DSL::Rules::Property

        prop_array(:only_if) do |item|
          unless item.is_a?(Proc) || [item].flatten.all? { |it| it.respond_to?(:truthy?) }
            raise ArgumentError, "Object passed to only_if must respond_to 'truthy?'"
          end
        end

        prop_array(:not_if) do |item|
          unless item.is_a?(Proc) || [item].flatten.all? { |it| it.respond_to?(:truthy?) }
            raise ArgumentError, "Object passed to not_if must respond_to 'truthy?'"
          end
        end

        #
        # Guard that can prevent execute of a rule if not satisfied
        #
        class Guard
          include Log

          #
          # Create a new Guard
          #
          # @param [Object] only_if Item or Proc to use as guard
          # @param [Object] not_if Item or Proc to use as guard
          #
          def initialize(run_context:, only_if: nil, not_if: nil)
            @run_context = run_context
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
            check(@only_if, check_type: :only_if,
                            event: event) && check(@not_if, check_type: :not_if, event: event)
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

            items.each { |item| logger.trace { "#{item} truthy? #{item.truthy?}" } }

            process_check(check_type: check_type, event: event, items: items, procs: procs)
          end

          #
          # Execute the guard check
          #
          # @param [Symbol] check_type :only_if or :not_if to check
          # @param [OpenHAB Event] event event to check if meets guard
          # @param [Array<Item>] items to check if satisfy criteria
          # @param [Array] procs to check if satisfy criteria
          #
          # @return [Boolean] True if criteria are satisfied, false otherwise
          #
          def process_check(check_type:, event:, items:, procs:)
            case check_type
            when :only_if then process_only_if(event, items, procs)
            when :not_if then  process_not_if(event, items, procs)
            else raise ArgumentError, "Unexpected check type: #{check_type}"
            end
          end

          #
          # Check not_if guard
          #
          # @param [OpenHAB Event] event to check if meets guard
          # @param [Array<Item>] items to check if satisfy criteria
          # @param [Array] procs to check if satisfy criteria
          #
          # @return [Boolean] True if criteria are satisfied, false otherwise
          #
          def process_not_if(event, items, procs)
            items.flatten.none?(&:truthy?) && procs.none? { |proc| @run_context.instance_exec(event, &proc) }
          end

          #
          # Check only_if guard
          #
          # @param [OpenHAB Event] event to check if meets guard
          # @param [Array<Item>] items to check if satisfy criteria
          # @param [Array] procs to check if satisfy criteria
          #
          # @return [Boolean] True if criteria are satisfied, false otherwise
          #
          def process_only_if(event, items, procs)
            items.flatten.all?(&:truthy?) && procs.all? { |proc| @run_context.instance_exec(event, &proc) }
          end
        end
      end
    end
  end
end
