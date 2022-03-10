---
layout: default
title: Every
nav_order: 5
has_children: false
parent: Triggers
grand_parent: Usage
---

# every

A simplified cron trigger with human-readable syntax.

| Value             | Description                              | Example    |
| ----------------- | ---------------------------------------- | ---------- |
| `:second`         | Execute rule every second                | :second    |
| `:minute`         | Execute rule very minute                 | :minute    |
| `:hour`           | Execute rule every hour                  | :hour      |
| `:day`            | Execute rule every day                   | :day       |
| `:week`           | Execute rule every week                  | :week      |
| `:month`          | Execute rule every month                 | :month     |
| `:year`           | Execute rule one a year                  | :year      |
| `:monday`         | Execute rule every Monday at midnight    | :monday    |
| `:monday`         | Execute rule every Monday at midnight    | :monday    |
| `:tuesday`        | Execute rule every Tuesday at midnight   | :tuesday   |
| `:wednesday`      | Execute rule every Wednesday at midnight | :wednesday |
| `:thursday`       | Execute rule every Thursday at midnight  | :thursday  |
| `:friday`         | Execute rule every Friday at midnight    | :friday    |
| `:saturday`       | Execute rule every Saturday at midnight  | :saturday  |
| `:sunday`         | Execute rule every Sunday at midnight    | :sunday    |
| [Numeric].seconds | Execute a rule every X seconds           | 5.seconds  |
| [Numeric].minutes | Execute rule every X minutes             | 3.minutes  |
| [Numeric].hours   | Execute rule every X minutes             | 10.hours   |

| Option | Description                                                                                                                                                    | Example                                        |
| ------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------- |
| `:at`  | Limit the execution to specific times of day. The value can either be a String or a [TimeOfDay]({{ site.baseurl }}{% link usage/misc/time_of_day.md %}) object | at: '16:45' or at: TimeOfDay.new(h: 16, m: 45) |

Note: The `[Numeric].seconds` specifies a [Duration]({{ site.baseurl }}{% link usage/misc/duration.md %}) / interval. 
A floating point can also be used to specify a fractional unit of time, e.g. `1.5.hours`

## Examples

```ruby
rule 'Log the rule name every minute' do |rule|
  description 'This rule will create a log every minute'
  every :minute
  run { logger.info "Rule '#{rule.name}' executed" }
end
```

```ruby
rule 'Log an entry at 11:21' do |rule|
  every :day, at: '11:21'
  run { logger.info("Rule #{rule.name} run at #{TimeOfDay.now}") }
end

# The above rule could also be expressed using TimeOfDay class as below

rule 'Log an entry at 11:21' do |rule|
  every :day, at: TimeOfDay.new(h: 11, m: 21)
  run { logger.info("Rule #{rule.name} run at #{TimeOfDay.now}") }
end
```

```ruby
rule 'Log an entry Wednesdays at 11:21' do |rule|
  every :wednesday, at: '11:21'
  run { logger.info("Rule #{rule.name} run at #{TimeOfDay.now}") }
end
```

```ruby
rule 'Every 5 seconds' do |rule|
  every 5.seconds
  run { logger.info "Rule #{rule.name} executed" }
end
```
