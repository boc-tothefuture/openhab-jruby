# frozen_string_literal: true

require 'java'
require 'core/duration'
require 'core/dsl/time_of_day'
require 'core/cron'

module OpenHAB
  module Core
    module DSL
      module Rule
        module Cron
          java_import org.openhab.core.automation.util.TriggerBuilder
          java_import org.openhab.core.config.core.Configuration

          using OpenHAB::Core::DSL::Tod::TimeOfDayRange
          include OpenHAB::Core::DSL::Rule
          extend OpenHAB::Core::Cron

          DAY_OF_WEEK_MAP = {
            monday: 'MON',
            tuesday: 'TUE',
            wednesday: 'WED',
            thursday: 'THU',
            friday: 'FRI',
            saturday: 'SAT',
            sunday: 'SUN'
          }.freeze

          DAY_OF_WEEK_EXPRESSION_MAP = DAY_OF_WEEK_MAP.transform_values { |v| cron_expression_map.merge(dow: v) }

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

          def map_to_cron(map)
            %i[second minute hour dom month dow].map { |field| map.fetch(field) }.join(' ')
          end

          # If an at time is provided, parse that and merge the new fields into the expression.
          def at_condition(expression_map, at_time)
            if at_time
              tod = (at_time.is_a? TimeOfDay) ? at_time : TimeOfDay.parse(at_time)
              expression_map = expression_map.merge(hour: tod.hour, minute: tod.minute, second: tod.second)
            end
            expression_map
          end

          def every(value, at: nil)
            case value
            when Symbol
              expression_map = EXPRESSION_MAP[value]
              expression_map = at_condition(expression_map, at) if at
              cron(map_to_cron(expression_map))
            when Duration
              cron(map_to_cron(value.cron_map))
            else
              raise 'Unknown interval' unless expression_map
            end
          end

          def time_of_day(tod)
            @triggers << Trigger.trigger(type: Trigger::TIME_OF_DAY, config: { 'time' => tod.to_s })
          end

          def cron(expression)
            @triggers << Trigger.trigger(type: Trigger::CRON, config: { 'cronExpression' => expression })
          end
        end
      end
    end
  end
end
