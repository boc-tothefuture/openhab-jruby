---
layout: default
title: Generic Trigger
nav_order: 7
has_children: false
parent: Triggers
grand_parent: Usage
---

# Trigger

`trigger` provides the ability to create a trigger type not already covered by the other methods.

| Options       | Description                                                                                                   |
| ------------- | ------------------------------------------------------------------------------------------------------------- |
| type_uid      | A string representing the trigger type uid                                                                    |
| configuration | a hash containing the configurations for the trigger, or a list of named keywords for the configuration items |

## Example

Create a trigger for the [PID Controller Automation](https://www.openhab.org/addons/automation/pidcontroller/) add-on.

```ruby
rule 'PID Control' do
  trigger 'pidcontroller.trigger',
    input: InputItem.name,
    setpoint: SetPointItem.name,
    kp: 10,
    ki: 10,
    kd: 10,
    kdTimeConstant: 1,
    loopTime: 1000

  run do |event|
    logger.info("PID controller command: #{event.command}")
    ControlItem << event.command
  end
end
```
