---
layout: default
title: OpenHAB JRuby Scripting
nav_order: 1
has_children: false
---

# OpenHAB JRuby Scripting

The OpenHAB JRuby scripting helpers bring the power of the Ruby language to OpenHAB. Rather than being a pure pass-through to OpenHAB, they provide a Ruby-like experience when building automation rules within OpenHAB.

## Discussion

Please see [this thread](https://community.openhab.org/t/jruby-openhab-rules-system/110598) on the OpenHAB forum for further discussion.  Ideas and suggestions are welcome.

## Quick Examples

The following examples are for file-based rules but most of them are applicable to [GUI rules]({{ site.baseurl }}{% link usage/ui-rules.md %}) as well.

### Trigger when an item changed state

```ruby
rule 'Control light based on door state' do
  changed Door_Sensor, to: [OPEN, CLOSED] 
  run { Cupboard_Light << Door_Sensor.open? } # Send a command using boolean
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

### Various ways of sending a command to an item

```ruby
Light1 << ON
Light1.on
Rollershutter1.up
ColorItem1.command '#ffff00'
DimmerItem1 << 100
Set_Temperature << '24 °C'
```

### Dealing with Number Items

```ruby
# Items:
# Number:Temperature Outside_Temperature e.g. 28 °C
# Number:Temperature Inside_Temperature e.g. 22 °C
temperature_difference = Outside_Temperature - Inside_Temperature
logger.info("Temperature difference: #{temperature_difference}") # "Temperature difference: 6 °C"
```

```ruby
# Items:
# Number:Power Solar_Panel_Power
# Number:Power Load_Power
# Number:Power Excess_Power
Excess_Power.update(Solar_Panel_Power - Load_Power)
```

### Detect change duration without creating an explicit timer

```ruby
rule 'Warn when garage door is open a long time' do
  changed Garage_Door, to: OPEN, for: 15.minutes
  run { say "Warning, the garage door is open" } # call TTS to the default audio sink
end
```

### Use timers

[Timers]({{ site.baseurl }}{% link usage/misc/timers.md %}) are created using `after` with an easier way to specify when it should execute, based on [duration]({{ site.baseurl }}{% link usage/misc/duration.md %}) syntax, e.g. `10.minutes` instead of using ZonedDateTime.

```ruby
rule 'simple timer' do
  changed Watering_System, to: ON
  run do
    after(5.minutes) { Watering_System.off }
  end
end
```

#### Rescheduling timers, the traditional way

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

#### Or use the timer "reentrant" feature to achieve the same thing

```ruby
rule 'automatic reentrant timer' do
  updated Motion_Sensor, to: OPEN
  run do
    Light_Item.ensure.on # 'ensure' only sends the command if it's not already on
    # Using a unique ID, this timer automatically reschedules when called again before 5 mins is up
    # This works similarly to the "expire" item profile
    after(5.minutes, id: Motion_Sensor) { Light_Item.off } 
  end
end

# timers[] is a pre-existing array that keeps track of reentrant timer ids
rule 'cancel timer' do
  changed Light_Item, to: OFF
  run { timers[Motion_Sensor]&.cancel_all }
end

```

#### Or use the timed command feature to achieve the same thing

The two timer examples above required an extra rule to keep track of the Light_Item state, so when it's turned off, 
the timer is cancelled. However, the [timed command]({{ site.baseurl }}{% link usage/items/index.md %}#timed-commands) 
feature in the next example handles that automatically for you.

```ruby
rule 'timed command' do
  updated Motion_Sensor, to: OPEN
  run { Light_Item.on for: 5.minutes } # it will turn it off after 5 minutes
end
```

### Automatic activation of exhaust fan based on humidity sensor

This uses the `evolution_rate` [persistence]({{ site.baseurl }}{% link usage/misc/persistence.md %}) feature, 
coupled with an easy way to specify [duration]({{ site.baseurl }}{% link usage/misc/duration.md %}).
It is accessed simply through `ItemName.persistence_function`.

```ruby
# Note: don't activate the exhaust fan if the bathroom light is off at night
# Sun_Elevation is an Astro item. Its state is positive during daylight
rule 'Humidity: Control ExhaustFan' do
  updated BathRoom_Humidity
  triggered do |humidity|
    evo_rate = humidity.evolution_rate 4.minutes, :influxdb
    logger.info("#{humidity.name} #{humidity} evolution_rate: #{evo_rate}")

    if (humidity > 70 && evo_rate > 15) || humidity > 85
      BathRoom_ExhaustFan.ensure.on if Sun_Elevation.positive? || BathRoom_Light.state.nil? || BathRoom_Light.on?
    elsif humidity < 70 || evo_rate < -5
      BathRoom_ExhaustFan.ensure.off
    end
  end
end
```
