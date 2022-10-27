# @title Updated

# updated 

Execute the rule when the state of an `item`, `group`, `members of group`, or `thing` is updated.

**Syntax:**
```ruby
updated <entity> [to:]
```

| Options  | Description                                                               | Example                                                       |
| -------- | ------------------------------------------------------------------------- | ------------------------------------------------------------- |
| `entity` | One or more item, group, member of group, or thing to monitor for updates | `updated SwitchItem1`<br/>`updated Switches.members`          |
| `to:`    | Only execute rule if update state matches to state                        | `to: 7` or `to: [7,14]` or `to: 7..14`  or `to: ->t {t.odd?}` |

The `to` option restricts the rule from running only if the updated state matches.

1. If the updated element being used as a trigger is a thing, the `to` option will accept symbols and strings, where the symbol matches the [supported status](https://www.openhab.org/docs/concepts/things.html).
2. The `to` option supports ranges
3. The `to` option supports procs

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
rule 'Execute rule when item is within a range' do
  updated Alarm_Mode, to: 7..14
  run { logger.info("Alarm Mode Updated to a value between 7 and 14")}
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

Works with procs:
```ruby
rule 'Execute rule when member of group is changed to an odd state' do
  updated AlarmModes.members, to: proc { |t| t.odd? }
  triggered { |item| logger.info("Group item #{item.id} updated")}
end
```

Works with lambda procs:
```ruby
rule 'Execute rule when member of group is changed to an odd state' do
  updated AlarmModes.members, to: -> t { t.odd? }
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
