---
layout: default
title: Changed
nav_order: 1
has_children: false
parent: Triggers
grand_parent: Usage
---

# changed

Execute the rule when an `item`, `group`, `member of group`, or `thing` changed state.

**Syntax:**

```ruby
changed entity [from:] [to:] [for:]
```

| Options  | Description                                                                                                            | Examples                                             |
| -------- | ---------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------- |
| `entity` | One or more item, group, member of group, or thing to monitor for changes                                              | `changed SwitchItem1`<br/>`changed Switches.members` |
| `from:`  | Optional: Only execute rule if previous state matches from state(s)                                                    | `from: OFF` or `from: 4..9`                          |
| `to:`    | Optional: Only execute rule if new state matches to state(s)                                                           | `to: ON` or `to: ->t { t.even? }`                    |
| `for:`   | Optional: Only execute rule if value stays changed for [duration]({{ site.baseurl }}{% link usage/misc/duration.md %}) | `for: 10.seconds`                                    |

The `from` and `to` options are enhanced compared to the rules DSL:

1. `from` and `to` accept arrays to match multiple states.
2. If the changed element being used as a trigger is a thing, the `to` and `from` values will accept symbols and strings, where the symbol matches the [supported status](https://www.openhab.org/docs/concepts/things.html#thing-status)
3. Support for ranges
4. Support for [procs/lambdas](https://ruby-doc.org/core-2.6/Proc.html) for complex state matches

The for parameter provides a method of only executing the rule if the value is changed for a specific duration.
This provides a built-in method of only executing a rule if a condition is true for a period of time without the
need to create dummy objects with the expire binding or make or manage your own timers.

For example, the code in [this design pattern](https://community.openhab.org/t/design-pattern-expire-binding-based-timers/32634) becomes (with no need to create the dummy object):
```ruby
rule "Execute rule when item is changed for specified duration" do
  changed Alarm_Mode, for: 20.seconds
  run { logger.info("Alarm Mode Updated")}
end
```

Multiple items can be separated with a comma:
```ruby
rule 'Execute rule when either sensor changed' do
  changed FrontMotion_Sensor, RearMotion_Sensor
  run { |event| logger.info("Motion detected by #{event.item.name}") }
end
```

Or in an array:
```ruby
SENSORS = [FrontMotion_Sensor, RearMotion_Sensor]
rule 'Execute rule when either sensor changed' do
  changed SENSORS
  run { |event| logger.info("Motion detected by #{event.item.name}") }
end
```

Group member trigger:
```
rule 'Execute rule when member changed' do
  changed Sensors.members
  run { |event| logger.info("Motion detected by #{event.item.name}") }
end
```
`for` parameter can be an item too:
```ruby
Alarm_Delay << 20

rule "Execute rule when item is changed for specified duration" do
  changed Alarm_Mode, for: Alarm_Delay
  run { logger.info("Alarm Mode Updated")}
end
```

You can optionally provide from and to states to restrict the cases in which the rule executes:
```ruby
rule 'Execute rule when item is changed to specific number, from specific number, for specified duration' do
  changed Alarm_Mode, from: 8, to: [14,12], for: 12.seconds
  run { logger.info("Alarm Mode Updated")}
end
```

Works with ranges:
```ruby
rule 'Execute rule when item is changed to a range of numbers, from a specific range of numbers, for specified duration' do
  changed Alarm_Mode, from: 8..10, to: 12..14, for: 12.seconds
  run { logger.info("Alarm Mode Updated")}
end
```

Works with endless ranges:
```ruby
rule 'Execute rule when item is changed to any number greater than 12'
  changed Alarm_Mode, to: (12..)   # Parenthesis required for endless ranges
  run { logger.info("Alarm Mode Updated")}
end
```

Works with procs:
```ruby
rule 'Execute rule when item state is changed from an odd number, to an even number, for specified duration' do
  changed Alarm_Mode, from: proc { |from| from.odd? }, to: proc {|to| to.even? }, for: 12.seconds
  run { logger.info("Alarm Mode Updated")}
end
```

Works with lambda procs:
```ruby
rule 'Execute rule when item state is changed from an odd number, to an even number, for specified duration' do
  changed Alarm_Mode, from: ->from { from.odd? }, to: ->to { to.even? }, for: 12.seconds
  run { logger.info("Alarm Mode Updated")}
end
```


Works with things as well:
```ruby
rule 'Execute rule when thing is changed' do
   changed things['astro:sun:home'], :from => :online, :to => :uninitialized
   run { |event| logger.info("Thing #{event.uid} status <trigger> to #{event.status}") }
end
```

Real world example:
```ruby
rule 'Log (or notify) when an exterior door is left open for more than 5 minutes' do
  changed ExteriorDoors.members, to: OPEN, for: 5.minutes
  triggered {|door| logger.info("#{door.id} has been left open!")}
end
```
