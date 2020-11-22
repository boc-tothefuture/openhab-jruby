# frozen_string_literal: true

require 'java'
require 'core/duration'
require 'core/dsl/time_of_day'

module Cron
  java_import org.openhab.core.automation.util.TriggerBuilder
  java_import org.openhab.core.config.core.Configuration

  using OpenHAB::Core::DSL::Tod::TimeOfDayRange

  EXPRESSION_MAP = {
    second: '* * * * * ?',
    minute: '0 * * * * ?',
    hour: '@hourly',
    day: '@daily',
    week: '@weekly',
    month: '@monthly',
    year: '@yearly'
  }.freeze

  def every(value)
    expression = case value
                 when Symbol then cron(EXPRESSION_MAP[value])
                 when Duration then cron(value.cron_expression)
                 when TimeOfDay then time_of_day(value)
                 end
    raise 'Unknown interval' if expression.nil?
  end

  def time_of_day(tod)
    @triggers << TriggerBuilder.create
                               .with_id(uuid)
                               .with_type_uid('timer.TimeOfDayTrigger')
                               .with_configuration(Configuration.new({ 'time' => tod.to_s }))
                               .build
  end

  def cron(expression)
    @triggers << TriggerBuilder.create
                               .with_id(uuid)
                               .with_type_uid('timer.GenericCronTrigger')
                               .with_configuration(Configuration.new({ 'cronExpression' => expression }))
                               .build
  end
end
