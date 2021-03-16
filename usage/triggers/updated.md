---
layout: default
title: Updated
nav_order: 4
has_children: false
parent: Triggers
grand_parent: Usage
---

# Updated 



| Options | Description                                        | Example                 |
| ------- | -------------------------------------------------- | ----------------------- |
| to      | Only execute rule if update state matches to state | `to: 7` or `to: [7,14]` |

Changed accepts Items, Things or Groups. 

The to value restricts the rule from running to only if the updated state matches. If the updated element being used as a trigger is a thing than the to and from values will accept symbols and strings, where the symbol matches the [supported status](https://www.openhab.org/docs/concepts/things.html). 

The examples below assume the following background:

| type   | name             | group      | state |
| ------ | ---------------- | ---------- | ----- |
| Number | Alarm_Mode       | AlarmModes | 7     |
| Number | Alarm_Mode_Other | AlarmModes | 7     |


```ruby
rule 'Execute rule when item is updated to any value' do
  updated Alarm_Mode
  run { logger.info("Alarm Mode Updated") }
end
```

```ruby
rule 'Execute rule when item is updated to specific number' do
  updated Alarm_Mode, to: 7
  run { logger.info("Alarm Mode Updated") }
end
```

```ruby
rule 'Execute rule when item is updated to one of many specific states' do
  updated Alarm_Mode, to: [7,14]
  run { logger.info("Alarm Mode Updated")}
end
```

```ruby
rule 'Execute rule when group is updated to any state' do
  updated AlarmModes
  triggered { |item| logger.info("Group #{item.id} updated")}
end  
```

```ruby
rule 'Execute rule when member of group is changed to any state' do
  updated AlarmModes.members
  triggered { |item| logger.info("Group item #{item.id} updated")}
end 
```

```ruby
rule 'Execute rule when member of group is changed to one of many states' do
  updated AlarmModes.members, to: [7,14]
  triggered { |item| logger.info("Group item #{item.id} updated")}
end
```

Works with things as well:
```ruby
rule 'Execute rule when thing is updated' do
   updated things['astro:sun:home'], :to => :uninitialized
   run { |event| logger.info("Thing #{event.uid} status <trigger> to #{event.status}") }
end
```
