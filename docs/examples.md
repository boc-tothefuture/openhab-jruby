# @title Examples

# Examples

The following examples are for file-based rules but most of them are applicable to [UI rules](../USAGE.md#ui-based-scripts) as well.

## Trigger when an item changed state

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

## Trigger when a group member changed state

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

See also: {group::OpenHAB::DSL::Rules::BuilderDSL::Triggers Triggers}

## Various ways of sending a command to an item

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

Each item type supports command helpers relevant to the type.
For example, a {SwitchItem} supports {SwitchItem#on on} and {SwitchItem#off off}.
See specific item types under {OpenHAB::Core::Items}

## Dealing with Item States

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

### Automatic activation of exhaust fan based on humidity sensor

This uses the `evolution_rate` {OpenHAB::Core::Items::Persistence persistence} feature,  coupled with an easy way to specify [duration](../USAGE.md#durations).
It is accessed simply through `ItemName.persistence_function`.

```ruby
# Note: don't activate the exhaust fan if the bathroom light is off at night
# Sun_Elevation is an Astro item. Its state is positive during daylight
rule "Humidity: Control ExhaustFan" do
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

## Gem Cleanup

The openHAB JRuby add-on will automatically download and install the latest version of the library according to the [settings in jruby.cfg](../USAGE.md#configuration).
Over time, the older versions of the library will accumulate in the gem_home directory.
The following code saved as `gem_cleanup.rb` or another name of your choice can be placed in the `automation/ruby` directory to perform uninstallation of the older gem versions every time openHAB starts up.

```ruby
require 'rubygems/commands/uninstall_command'

cmd = Gem::Commands::UninstallCommand.new

# uninstall all the older versions of the openhab-jrubyscripting gems
Gem::Specification.find_all
                  .select { |gem| gem.name == 'openhab-jrubyscripting' }
                  .sort_by(&:version)
                  .tap(&:pop) # don't include the latest version
                  .each do |gem|
  cmd.handle_options ['-x', '-I', gem.name, '--version', gem.version.to_s]
  cmd.execute
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
