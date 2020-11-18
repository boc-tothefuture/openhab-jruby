# frozen_string_literal: true

require 'java'
require 'core/duration'

module Cron
  java_import org.openhab.core.automation.util.TriggerBuilder
  java_import org.openhab.core.config.core.Configuration

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
                 when Symbol then EXPRESSION_MAP[value]
                 when Duration then value.cron_expression
                 end
    raise 'Unknown interval' if expression.nil?

    cron(expression)
  end

  def cron(expression)
    @triggers << TriggerBuilder.create
                               .with_id(uuid)
                               .with_type_uid('timer.GenericCronTrigger')
                               .with_configuration(Configuration.new({ 'cronExpression' => expression }))
                               .build
  end
end
