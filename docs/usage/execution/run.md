---
layout: default
title: Run
nav_order: 1
has_children: false
parent: Execution Blocks
grand_parent: Usage
---


# Run
The run property is the automation code that is executed when a rule is triggered.  This property accepts a block of code and executes it. The block is automatically passed an event object which can be used to access multiple properties about the triggering event.  The code for the automation can be entirely within the run block can call methods defined in the ruby script.

## State/Update Event Properties
The following properties exist when a run block is triggered from an [updated](#updated) or [changed](#changed) trigger. 

| Property | Description                      |
| -------- | -------------------------------- |
| item     | Triggering item                  |
| state    | Changed state of triggering item |
| last     | Last state of triggering item    |

## Command Event Properties
The following properties exist when a run block is triggered from a [received_command](#received_command) trigger.

| Property | Description          |
| -------- | -------------------- |
| command  | Command sent to item |

## Thing Event Properties
The following properties exist when a run block is triggered from an  [updated](#updated) or [changed](#changed) trigger on a Thing.

| Property | Description                                                       |
| -------- | ----------------------------------------------------------------- |
| uid      | UID of the triggered Thing                                        |
| last     | Status before Change for thing (only valid on Change, not update) |
| status   | Current status of the triggered Thing                             |



`{}` Style used for single line blocks
```ruby
rule 'Access Event Properties' do
  changed TestSwitch
  run { |event| logger.info("#{event.item.id} triggered from #{event.last} to #{event.state}") }
end
```

`do/end` style used for multi-line blocks
```ruby
rule 'Multi Line Run Block' do
  changed TestSwitch
  run do |event|
    logger.info("#{event.item.id} triggered")
    logger.info("from #{event.last}") if event.last
    logger.info("to #{event.state}") if event.state
   end
end
```

Rules can have multiple run blocks and they are executed in order, Useful when used in combination with delay
```ruby
rule 'Multiple Run Blocks' do
  changed TestSwitch
  run { |event| logger.info("#{event.item.id} triggered") }
  run { |event| logger.info("from #{event.last}") if event.last }
  run { |event| logger.info("to #{event.state}") if event.state  }
end

```
