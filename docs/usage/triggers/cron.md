---
layout: default
title: Cron
nav_order: 4
has_children: false
parent: Triggers
grand_parent: Usage
---

# cron

There are three ways of creating a cron trigger:

* Using an [OpenHAB style cron expression](https://www.openhab.org/docs/configuration/rules-dsl.html#time-based-triggers) 
* Specifying each cron field as named arguments
* Using a simpler [every]({{ site.baseurl }}{% link usage/triggers/every.md %}) syntax

## Using a cron expression

```ruby
rule 'Using Cron Syntax' do
  cron '43 46 13 ? * ?'
  run { logger.info "Cron rule executed" }
end
```

## Using cron fields

Cron Field Names

| Field     | Description                                      |
| --------- | ------------------------------------------------ |
| `second:` | Defaults to `0` when not specified               |
| `minute:` | Defaults to `0` when not specified               |
| `hour:`   | Defaults to `0` when not specified               |
| `dom:`    | Day of month. Defaults to `?` when not specified |
| `month:`  | Defaults to `*` when not specified               |
| `dow:`    | Day of week. Defaults to `?` when not specified  |
| `year:`   | Defaults to `*` when not specified               |

Each field is optional, but at least one must be specified. The same rules for the standard [cron expression](https://www.quartz-scheduler.org/documentation/quartz-2.2.2/tutorials/tutorial-lesson-06.html) 
apply for each field.
For example, multiple values can be separated with a comma within a string. Omitted fields will default to `*` or `?` 
as applicable.

```ruby
# Run every 3 minutes on Monday to Friday
# equivalent to the cron expression '0 */3 * ? * MON-FRI *'
rule 'Using cron fields' do
  cron second: 0, minute: '*/3', dow: 'MON-FRI'
  run { logger.info "Cron rule executed" }
end
```

## Using Every syntax

See: [every]({{ site.baseurl }}{% link usage/triggers/every.md %})