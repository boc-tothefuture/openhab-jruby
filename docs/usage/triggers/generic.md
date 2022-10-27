# @title Generic Trigger

# trigger

`trigger` provides the ability to create a trigger type not already covered by the other methods.

| Options       | Description                                     |
| ------------- | ----------------------------------------------- |
| type_uid      | A string representing the trigger type uid      |
| configuration | named keywords for the trigger's configurations |

## Example

### PID Controller Trigger

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

### DateTime Trigger

This trigger type is available in openHAB 3.3.0.M4+

```ruby
rule 'DateTime Trigger' do
  description 'Triggers at a time specified in MyDateTimeItem'
  trigger 'timer.DateTimeTrigger', itemName: MyDateTimeItem.name
  run do 
    logger.info("DateTimeTrigger has been triggered")
  end
end
```
