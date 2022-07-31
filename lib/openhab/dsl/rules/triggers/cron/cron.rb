# frozen_string_literal: true

require 'java'
require 'openhab/dsl/rules/triggers/trigger'

module OpenHAB
  module DSL
    module Rules
      #
      # Cron type rules
      #
      module Triggers
        #
        # Create a rule that executes at the specified interval
        #
        # @param [Object] value String, Symbol, Duration, or MonthDay to execute this rule
        # @param [Object] at TimeOfDay or String representing TimeOfDay in which to execute rule
        # @param [Object] attach object to be attached to the trigger
        #
        #
        def every(value, at: nil, attach: nil)
          return every(MonthDay.parse(value), at: at, attach: attach) if value.is_a? String

          @ruby_triggers << [:every, value, { at: at }]

          cron_expression = case value
                            when Symbol then Cron.from_symbol(value, at)
                            when Java::JavaTime::Duration then Cron.from_duration(value, at)
                            when Java::JavaTime::MonthDay then Cron.from_monthday(value, at)
                            else raise ArgumentError, 'Unknown interval'
                            end
          cron(cron_expression, attach: attach)
        end

        #
        # Create a OpenHAB Cron trigger
        #
        # @param [String] expression OpenHAB style cron expression
        # @param [Object] attach object to be attached to the trigger
        # @param [Hash] fields cron expression elements (second, minute, hour, dom, month, dow, year)
        #
        def cron(expression = nil, attach: nil, **fields)
          if fields.any?
            raise ArgumentError, 'Cron elements cannot be used with a cron expression' if expression

            cron_expression = Cron.from_fields(fields)
            return cron(cron_expression, attach: attach)
          end

          raise ArgumentError, 'Missing cron expression or elements' unless expression

          cron = Cron.new(rule_triggers: @rule_triggers)
          cron.trigger(config: { 'cronExpression' => expression }, attach: attach)
        end

        #
        # Creates cron triggers
        #
        class Cron < Trigger
          # Trigger ID for Watch Triggers
          CRON_TRIGGER_MODULE_ID = 'jsr223.jruby.CronTrigger'

          #
          # Returns a default map for cron expressions that fires every second
          # This map is usually updated via merge by other methods to refine cron type triggers.
          #
          # @return [Hash] Map with symbols for :seconds, :minute, :hour, :dom, :month, :dow
          #   configured to fire every second
          #
          CRON_EXPRESSION_MAP =
            {
              second: '*',
              minute: '*',
              hour: '*',
              dom: '?',
              month: '*',
              dow: '?',
              year: '*'
            }.freeze
          private_constant :CRON_EXPRESSION_MAP

          # @return [Hash] Map of days of the week from symbols to to OpenHAB cron strings
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

          # @return [Hash] Converts the DAY_OF_WEEK_MAP to map used by Cron Expression
          DAY_OF_WEEK_EXPRESSION_MAP = DAY_OF_WEEK_MAP.transform_values { |v| CRON_EXPRESSION_MAP.merge(dow: v) }

          private_constant :DAY_OF_WEEK_EXPRESSION_MAP

          # @return [Hash] Create a set of cron expressions based on different time intervals
          EXPRESSION_MAP = {
            second: CRON_EXPRESSION_MAP,
            minute: CRON_EXPRESSION_MAP.merge(second: '0'),
            hour: CRON_EXPRESSION_MAP.merge(second: '0', minute: '0'),
            day: CRON_EXPRESSION_MAP.merge(second: '0', minute: '0', hour: '0'),
            week: CRON_EXPRESSION_MAP.merge(second: '0', minute: '0', hour: '0', dow: 'MON'),
            month: CRON_EXPRESSION_MAP.merge(second: '0', minute: '0', hour: '0', dom: '1'),
            year: CRON_EXPRESSION_MAP.merge(second: '0', minute: '0', hour: '0', dom: '1', month: '1')
          }.merge(DAY_OF_WEEK_EXPRESSION_MAP).freeze

          private_constant :EXPRESSION_MAP

          #
          # Create a cron map from a duration
          #
          # @param [Java::JavaTime::Duration] duration
          # @param [Object] at TimeOfDay or String representing time of day
          #
          # @return [Hash] map describing cron expression
          #
          def self.from_duration(duration, at)
            raise ArgumentError, '"at" cannot be used with duration' if at

            map_to_cron(duration_to_map(duration))
          end

          #
          # Create a cron map from a MonthDay
          #
          # @param [Java::JavaTime::MonthDay] monthday a {MonthDay} object
          # @param [Object] at TimeOfDay or String representing time of day
          #
          # @return [Hash] map describing cron expression
          #
          def self.from_monthday(monthday, at)
            expression_map = EXPRESSION_MAP[:day].merge(month: monthday.month_value, dom: monthday.day_of_month)
            expression_map = at_condition(expression_map, at) if at
            map_to_cron(expression_map)
          end

          #
          # Create a cron map from a symbol
          #
          # @param [Symbol] symbol
          # @param [Object] at TimeOfDay or String representing time of day
          #
          # @return [Hash] map describing cron expression created from symbol
          #
          def self.from_symbol(symbol, at)
            expression_map = EXPRESSION_MAP[symbol]
            expression_map = at_condition(expression_map, at) if at
            map_to_cron(expression_map)
          end

          #
          # Create a cron map from cron elements
          #
          # @param [Hash] fields Cron fields (second, minute, hour, dom, month, dow, year)
          #
          # @return [Hash] map describing cron expression
          #
          def self.from_fields(fields)
            fields = fields.transform_values { |value| value.to_s.gsub(/\s+/, '') }
            expression_map = CRON_EXPRESSION_MAP.merge(fields)
            map_to_cron(expression_map)
          end

          #
          # Map cron expression to to cron string
          #
          # @param [Map] map of cron expression
          #
          # @return [String] OpenHAB cron string
          #
          def self.map_to_cron(map)
            %i[second minute hour dom month dow year].map { |field| map.fetch(field) }.join(' ')
          end

          #
          # Convert a Java Duration to a map for the map_to_cron method
          #
          # @param duration [Java::JavaTime::Duration] The duration object
          #
          # @return [Hash] a map suitable for map_to_cron
          #
          def self.duration_to_map(duration)
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
          def self.at_condition(expression_map, at_time)
            if at_time
              tod = at_time.is_a?(TimeOfDay::TimeOfDay) ? at_time : TimeOfDay::TimeOfDay.parse(at_time)
              expression_map = expression_map.merge(hour: tod.hour, minute: tod.minute, second: tod.second)
            end
            expression_map
          end

          #
          # Create a cron trigger based on item type
          #
          # @param [Config] config Rule configuration
          # @param [Object] attach object to be attached to the trigger
          #
          #
          def trigger(config:, attach:)
            append_trigger(type: CRON_TRIGGER_MODULE_ID, config: config, attach: attach)
          end
        end
      end
    end
  end
end
