# frozen_string_literal: true

require 'java'
require 'core/dsl/time_of_day'
require 'core/cron'

module OpenHAB
  module Core
    module DSL
      module Rule
        #
        # Cron type rules
        #
        module Cron
          java_import org.openhab.core.automation.util.TriggerBuilder
          java_import org.openhab.core.config.core.Configuration

          include OpenHAB::Core::DSL::Rule
          extend OpenHAB::Core::Cron

          # @return [Map] Map of days of the week from symbols to to OpenHAB cron strings
          DAY_OF_WEEK_MAP = {
            monday: 'MON',
            tuesday: 'TUE',
            wednesday: 'WED',
            thursday: 'THU',
            friday: 'FRI',
            saturday: 'SAT',
            sunday: 'SUN'
          }.freeze

          private_constant :DAY_OF_WEEK_MAP

          # @return [MAP] Converts the DAY_OF_WEEK_MAP to map used by Cron Expression
          DAY_OF_WEEK_EXPRESSION_MAP = DAY_OF_WEEK_MAP.transform_values { |v| cron_expression_map.merge(dow: v) }

          private_constant :DAY_OF_WEEK_EXPRESSION_MAP

          # @return [Map] Create a set of cron expressions based on different time intervals
          EXPRESSION_MAP = {
            second: cron_expression_map,
            minute: cron_expression_map.merge(second: '0'),
            hour: cron_expression_map.merge(second: '0', minute: '0'),
            day: cron_expression_map.merge(second: '0', minute: '0', hour: '0'),
            week: cron_expression_map.merge(second: '0', minute: '0', hour: '0', dow: 'MON'),
            month: cron_expression_map.merge(second: '0', minute: '0', hour: '0', dom: '1'),
            year: cron_expression_map.merge(second: '0', minute: '0', hour: '0', dom: '1', month: '1')
          }.merge(DAY_OF_WEEK_EXPRESSION_MAP)
                           .freeze

          private_constant :EXPRESSION_MAP

          #
          # Create a rule that executes at the specified interval
          #
          # @param [Object] value Symbol or Duration to execute this rule
          # @param [Object] at TimeOfDay or String representing TimeOfDay in which to execute rule
          #
          #
          def every(value, at: nil)
            case value
            when Symbol
              expression_map = EXPRESSION_MAP[value]
              expression_map = at_condition(expression_map, at) if at
              cron(map_to_cron(expression_map))
            when Java::JavaTime::Duration
              raise ArgumentError, '"at" cannot be used with duration' if at

              cron(map_to_cron(duration_to_map(value)))
            else
              raise ArgumentExpression, 'Unknown interval' unless expression_map
            end
          end

          #
          # Create a OpenHAB Cron trigger
          #
          # @param [String] expression OpenHAB style cron expression
          #
          def cron(expression)
            @triggers << Trigger.trigger(type: Trigger::CRON, config: { 'cronExpression' => expression })
          end

          private

          #
          # Map cron expression to to cron string
          #
          # @param [Map] map of cron expression
          #
          # @return [String] OpenHAB cron string
          #
          def map_to_cron(map)
            %i[second minute hour dom month dow].map { |field| map.fetch(field) }.join(' ')
          end

          #
          # Convert a Java Duration to a map for the map_to_cron method
          #
          # @param duration [Java::JavaTime::Duration] The duration object
          #
          # @return [Hash] a map suitable for map_to_cron
          #
          def duration_to_map(duration)
            if duration.to_millis_part.zero? && duration.to_nanos_part.zero? && duration.to_days.zero?
              %i[second minute hour].each do |unit|
                to_unit_part = duration.public_send("to_#{unit}s_part")
                next unless to_unit_part.positive?

                to_unit = duration.public_send("to_#{unit}s")
                break unless to_unit_part == to_unit

                return EXPRESSION_MAP[unit].merge(unit => "*/#{to_unit}")
              end
            end
            raise ArgumentError, "Cron Expression not supported for duration: #{duration}"
          end

          #
          # If an at time is provided, parse that and merge the new fields into the expression.
          #
          # @param [<Type>] expression_map <description>
          # @param [<Type>] at_time <description>
          #
          # @return [<Type>] <description>
          #
          def at_condition(expression_map, at_time)
            if at_time
              tod = (at_time.is_a? TimeOfDay) ? at_time : TimeOfDay.parse(at_time)
              expression_map = expression_map.merge(hour: tod.hour, minute: tod.minute, second: tod.second)
            end
            expression_map
          end
        end
      end
    end
  end
end
