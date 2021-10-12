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

| Property   | Description                                            |
| ---------- | ------------------------------------------------------ |
| item       | Triggering item                                        |
| state      | New state of triggering item (nil if NULL or UNDEF)    |
| state?     | New state of triggering item is not NULL or UNDEF      |
| null?      | New state is NULL                                      |
| undef?     | New state is UNDEF                                     |
| was        | Prior state of triggering item (nil if NULL or UNDEF)  |
| was?       | Prior state of triggering item was not NULL or UNDEF   |
| was_null?  | Prior state was NULL                                   |
| was_undef? | Prior state was UNDEF                                  |
| attachment | Optional user provided attachment to trigger           |

For compatibility, `last` is also aliased to `was`.

## Command Event Properties
The following properties exist when a run block is triggered from a [received_command](#received_command) trigger.

| Property     | Description                                  |
|--------------|----------------------------------------------|
| command      | Command sent to item                         |
| refresh?     | If the command is REFRESH                    |
| on?          | If the command is ON                         |
| off?         | If the command is OFF                        |
| increase?    | If the command is INCREASE                   |
| decrease?    | If the command is DECREASE                   |
| up?          | If the command is UP                         |
| down?        | If the command is DOWN                       |
| stop?        | If the command is STOP                       |
| move?        | If the command is MOVE                       |
| play?        | If the command is PLAY                       |
| pause?       | If the command is PAUSE                      |
| rewind?      | If the command is REWIND                     |
| fastforward? | If the command is FASTFORWARD                |
| next?        | If the command is NEXT                       |
| previous?    | If the command is PREVIOUS                   |
| attachment   | Optional user provided attachment to trigger |

## Thing Event Properties
The following properties exist when a run block is triggered from an  [updated](#updated) or [changed](#changed) trigger on a Thing.

| Property   | Description                                                       |
|------------|-------------------------------------------------------------------|
| uid        | UID of the triggered Thing                                        |
| last       | Status before Change for thing (only valid on Change, not update) |
| status     | Current status of the triggered Thing                             |
| attachment | Optional user provided attachment to trigger                      |



`{}` Style used for single line blocks
```ruby
rule 'Access Event Properties' do
  changed TestSwitch
  run { |event| logger.info("#{event.item.id} triggered from #{event.was} to #{event.state}") }
end
```

`do/end` style used for multi-line blocks
```ruby
rule 'Multi Line Run Block' do
  changed TestSwitch
  run do |event|
    logger.info("#{event.item.id} triggered")
    logger.info("from #{event.was}") if event.was
    logger.info("to #{event.state}") if event.state
   end
end
```

Rules can have multiple run blocks and they are executed in order, Useful when used in combination with delay
```ruby
rule 'Multiple Run Blocks' do
  changed TestSwitch
  run { |event| logger.info("#{event.item.id} triggered") }
  run { |event| logger.info("from #{event.was}") if event.was }
  run { |event| logger.info("to #{event.state}") if event.state  }
end

```
