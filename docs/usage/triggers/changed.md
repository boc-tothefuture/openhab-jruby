---
layout: default
title: Changed
nav_order: 3
has_children: false
parent: Triggers
grand_parent: Usage
---


# Changed


| Options | Description                                               | Example         |
| ------- | --------------------------------------------------------- | --------------- |
| from    | Only execute rule if previous state matches from state(s) | from: OFF       |
| to      | Only execute rule if new state matches to state(s)        | to: ON          |
| for     | Only execute rule if value stays changed for duration     | for: 10.seconds |

Changed accepts Items, Things or Groups. 
To and from accept arrays to match multiple states

The from and to values operate exactly as they do in the DSL and Python rules with the exception of operating on Things.  If changed element being used as a trigger is a thing than the to and from values will accept symbols and strings, where the symbol matches the [supported status](https://www.openhab.org/docs/concepts/things.html). 

The for parameter provides a method of only executing the rule if the value is changed for a specific duration.  This provides a built-in method of only executing a rule if a condition is true for a period of time without the need to create dummy objects with the expire binding or make or manage your own timers.

For example, the code in [this design pattern](https://community.openhab.org/t/design-pattern-expire-binding-based-timers/32634) becomes (with no need to create the dummy object):
```ruby
rule "Execute rule when item is changed for specified duration" do
  changed Alarm_Mode, for: 20.seconds
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
