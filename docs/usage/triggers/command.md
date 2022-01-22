---
layout: default
title: Received Command
nav_order: 5
has_children: false
parent: Triggers
grand_parent: Usage
---


# Received_Command


| Options  | Description                                                          | Example                                  |
| -------- | -------------------------------------------------------------------- | ---------------------------------------- |
| command  | Only execute rule if the command matches this/these command/commands | `command: 7` or  `command: ->c {c.odd?}` |
| commands | Alias of command, may be used if matching more than one command      | `commands: [7,14]` or  `commands: 7..14` |

The `command` or `commands` option restricts the rule from running only if the command matches the supplied arguments
1. The `command` or `commands` option supports an array of commands
2. The `command` or `commands` option supports ranges
3. The `command` or `commands` option supports procs

Ranges are useful to match a range of commands, procs support complex matches

The examples below assume the following background:

| type   | name             | group      | state |
| ------ | ---------------- | ---------- | ----- |
| Number | Alarm_Mode       | AlarmModes | 7     |
| Number | Alarm_Mode_Other | AlarmModes | 7     |


```ruby
rule 'Execute rule when item received command' do
  received_command Alarm_Mode
  run { |event| logger.info("Item received command: #{event.command}" ) }
end
```

```ruby
rule 'Execute rule when item receives specific command' do
  received_command Alarm_Mode, command: 7
  run { |event| logger.info("Item received command: #{event.command}" ) }
end
```

```ruby
rule 'Execute rule when item receives one of many specific commands' do
  received_command Alarm_Mode, commands: [7,14]
  run { |event| logger.info("Item received command: #{event.command}" ) }
end
```

```ruby
rule 'Execute rule when group receives a specific command' do
  received_command AlarmModes
  triggered { |item| logger.info("Group #{item.id} received command")}
end
```

```ruby
rule 'Execute rule when member of group receives any command' do
  received_command AlarmModes.members
  triggered { |item| logger.info("Group item #{item.id} received command")}
end
```

```ruby
rule 'Execute rule when member of group is changed to one of many states' do
  received_command AlarmModes.members, commands: [7,14]
  triggered { |item| logger.info("Group item #{item.id} received command")}
end
```

```ruby
rule 'Execute rule when item receives a range of commands' do
  received_command Alarm_Mode, commands: 7..14
  run { |event| logger.info("Item received command: #{event.command}" ) }
end
```

Works with procs:
```ruby
rule 'Execute rule when Alarm Mode command is odd' do
  received_command Alarm_Mode, command: proc { |c| c.odd? }
  run { |event| logger.info("Item received command: #{event.command}" ) }
end
```

Works with lambda procs:
```ruby
rule 'Execute rule when Alarm Mode command is odd' do
  received_command Alarm_Mode, command: -> c { c.odd? }
  run { |event| logger.info("Item received command: #{event.command}" ) }
end
```