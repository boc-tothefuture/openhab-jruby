# @title Examples

## Detailed Examples

* [Rule Conversions](examples/conversions.md)
* [Gem Cleanup](examples/gem_cleanup.md)
* [Generated Rules](examples/generated_rule.md)
* [How Do I...?](examples/how_do_i.md)

## File-based Rules

The following examples are for file-based rules but most of them are applicable to [GUI rules](usage.md#creating-rules-in-main-ui) as well.

### Trigger when an item changed state

```ruby
rule 'Turn on light when sensor changed to open' do
  changed Door_Sensor, to: OPEN 
  run { Cupboard_Light.on }
end
```

Use multiple triggers

```ruby
rule 'Control light based on multiple doors' do
  changed Door_Sensor1, to: OPEN
  changed Door_Sensor2, to: OPEN
  run { Cupboard_Light.on }
end

# Which is the same as:
rule 'Control light based on multiple doors' do
  changed Door_Sensor1, Door_Sensor2, to: OPEN
  run { Cupboard_Light.on }
end
```

Check against multiple states

```ruby
rule 'Control light based on door state' do
  changed Door_Sensor, to: [OPEN, CLOSED]
  run { Cupboard_Light << Door_Sensor.open? } # Send a boolean command to a Switch Item
end
```

### Trigger when a group member changed state:

```ruby
# Assumption: Motion sensor items are named using the pattern RoomName_Motion
# and Light switch items are named with the pattern RoomName_Light
rule 'Generic motion rule' do
  changed Motion_Sensors.members, to: ON
  run do |event|
    light = items[event.item.name.sub('_Motion', '_Light')] # Lookup item name from a string
    light&.on 
  end
end
```

See also: {group::OpenHAB::DSL::Rules::Builder::Triggers Triggers}

### Various ways of sending a command to an item

```ruby
# Using the shovel operator
Light1 << ON
DimmerItem1 << 100
Set_Temperature << '24 °C'     

# Using command predicates
Light1.on
Rollershutter1.up  
Player1.play

# Using .command
ColorItem1.command '#ffff00'
ColorItem1.command {r: 255, g: 0xFF, b: 0} 

# Send a command to all the array members
# Note The << operator doesn't send a command here because it's for appending to the array
[SwitchItem1, SwitchItem2, SwitchItem3].on           
[RollerItem1, RollerItem2, RollerItem3].down    
[NumberItem1, NumberItem2, NumberItem3].command 100  
```

Each item type supports command predicates relevant to the type. For example, a 
{SwitchItem} supports {SwitchItem#on on} and {SwitchItem#off off}. 
See specific item types under {OpenHAB::Core::Items}

### Dealing with Item States

```ruby
# Items:
# Number:Temperature Outside_Temperature e.g. 28 °C
# Number:Temperature Inside_Temperature e.g. 22 °C
temperature_difference = Outside_Temperature.state - Inside_Temperature.state
logger.info("Temperature difference: #{temperature_difference}") # "Temperature difference: 6 °C"
```

Items have predicates to query its state.

```ruby
Switch1.on?    # => true if Switch1.state == ON
Shutter1.up?   # => true if Shutter1.state == UP
```

### Detect change duration without creating an explicit timer

```ruby
rule 'Warn when garage door is open a long time' do
  changed Garage_Door, to: OPEN, for: 15.minutes
  run { say "Warning, the garage door is open" } # call TTS to the default audio sink
end
```

### Use timers

Timers are created using {after after} with an easier way to specify when it should execute,
based on [duration](docs/usage/misc/time.md#Durations) syntax, e.g. `10.minutes` instead of using ZonedDateTime.

```ruby
rule 'simple timer' do
  changed Watering_System, to: ON
  run do
    after(5.minutes) { Watering_System.off }
  end
end
```

#### Rescheduling timers manually

```ruby
@timer = nil # variables starting with @ are instance variables

rule 'reschedule timer' do
  updated Motion_Sensor, to: OPEN
  run do
    Light_Item.on
    if (@timer.nil?)
      @timer = after(5.minutes) { Light_Item.off } # This is the equivalent of createTimer() in rulesdsl
    else
      @timer.reschedule # This automatically reschedules it for the original duration (5 minutes)
      # To reschedule it a different duration, use @timer.reschedule 10.minutes
    end
  end
end

rule 'cancel timer' do
  changed Light_Item, to: OFF
  run { @timer&.cancel }
end

```

#### Reentrant Timer

Timers with `id` will automatically reschedule itself when executed again, 
and can be managed through {OpenHAB::DSL.timers timers[]} hash

```ruby
rule 'automatic reentrant timer' do
  updated Motion_Sensor, to: OPEN
  run do
    Light_Item.ensure.on # 'ensure' only sends the command if it's not already on
    # Using a unique ID, this timer automatically reschedules when called again before 5 mins is up
    after(5.minutes, id: Motion_Sensor) { Light_Item.off } 
  end
end

# timers[] is a built-in hash that keeps track of reentrant timer ids
rule 'cancel timer' do
  changed Light_Item, to: OFF
  run { timers[Motion_Sensor]&.cancel }
end
```

#### Using Timed Command Feature

The two timer examples above require an extra rule to keep track of the Light_Item state, so when it's turned off,
the timer is cancelled. However, the {OpenHAB::DSL::Items::TimedCommand timed command} 
feature in the next example handles that automatically for you.

```ruby
rule 'timed command' do
  updated Motion_Sensor, to: OPEN
  run { Light_Item.on for: 5.minutes } # it will turn it off after 5 minutes
end
```

### Automatic activation of exhaust fan based on humidity sensor

This uses the `evolution_rate` {OpenHAB::Core::Items::Persistence persistence}
feature,  coupled with an easy way to specify
[duration](docs/usage/misc/time.md#Durations).
It is accessed simply through `ItemName.persistence_function`.

```ruby
# Note: don't activate the exhaust fan if the bathroom light is off at night
# Sun_Elevation is an Astro item. Its state is positive during daylight
rule 'Humidity: Control ExhaustFan' do
  updated BathRoom_Humidity
  triggered do |humidity|
    evo_rate = humidity.evolution_rate(4.minutes.ago, :influxdb)
    logger.info("#{humidity.name} #{humidity.state} evolution_rate: #{evo_rate}")

    if (humidity.state > 70 && evo_rate > 15) || humidity.state > 85
      BathRoom_ExhaustFan.ensure.on if Sun_Elevation.state.positive? || BathRoom_Light.state.nil? || BathRoom_Light.on?
    elsif humidity.state < 70 || evo_rate < -5
      BathRoom_ExhaustFan.ensure.off
    end
  end
end
```

## UI rules

### Reset the switch that triggered the rule after 5 seconds

Trigger defined as:

* When: a member of an item group receives a command
* Group: `Reset_5Seconds`
* Command: `ON`

```ruby
logger.info("#{event.item.name} Triggered the rule")
after 5.seconds do
  event.item.off
end
```

### Update a DateTime Item with the current time when a motion sensor is triggered

Given the following group and items:

```
Group MotionSensors
Switch Sensor1 (MotionSensors)
Switch Sensor2 (MotionSensors)

DateTime Sensor1_LastMotion
DateTime Sensor2_LastMotion
```

Trigger defined as:

* When: the state of a member of an item group is updated
* Group: `MotionSensors`
* State: `ON`

```ruby
logger.info("#{event.item.name} Triggered")
items["#{event.item_name}_LastMotion"].update Time.now
```
