---
layout: default
title: How Do I...?
has_children: false
parent: Examples
---

# How Do I...?
{:.no_toc}

* toc
{:toc}

## Items

### Get an Item

Items and Groups are referred to by their name:

```ruby
My_Item
```

```ruby
gWindowBlinds
```

Items can be retrieved dynamically:

```ruby
the_item = items['My_Item'] # This returns an item object, not just its state
# For all intents and purposes, the_item variable is the same as My_Item in the previous example
```

### Get the Item's Name as a String

```ruby
My_Item.name
```

### Get the Item's Label

```ruby
My_Item.label
```

### Get a Related Item

```ruby
my_light_item = items[My_Switch.name.sub('_Switch', '_Light')]
```

### Send a Command to an Item

These three variants do the same thing:

```ruby
My_Item.on
```

```ruby
My_Item.command ON
```

```ruby
My_Item << ON
```

Note: all possible commands are supported on the corresponding item types, e.g. `on`, `off`, `up`, `down`, `play`, `pause`, `stop`, etc. 
For more details, see the individual item type sub-sections under [Items]({{ site.baseurl }}{% link usage/items/index.md %})

### Send a Command to an Item Only When Its State is Different

```ruby
My_Item.ensure.on
```

```ruby
My_Item.ensure.command ON
```

```ruby
My_Item.ensure << ON
```

### Send a Timed Command

A [Timed command]({{ site.baseurl }}{% link usage/items/index.md %}#timed-commands) is similar to the OpenHAB Item's [expire parameter](https://www.openhab.org/docs/configuration/items.html#parameter-expire)
but it offers more flexibility. It removes the need to manually create a timer.

```ruby
My_Switch.on for: 5.minutes
```

### Send an Update to an Item

```ruby
My_Switch.update ON
```

### Get State of an Item

Item's state is inferred in the item object. Most operations can be done directly using the item itself. Explicitly, `My_Item.state` can also be used 
to refer to the item's state.

```ruby
if My_Item == ON
  # do something
end

# This syntax is equivalent and preferred:
if My_Item.on?
  # do something
end

# Items can be compared directly against its state or against another item's state
if Indoor_Temperature > '20 °C' || Indoor_Temperature > Outdoor_Temperature
  # do something
end

# This is possible but unnecessary
Indoor_Temperature.state > '20 °C' || Indoor_Temperature.state > Outdoor_Temperature.state
```

Note: all boolean helper methods are available depending on the item / state type.
For example `up?`, `down?`, `closed?`, `open?`, etc.

### Check if an Item's state is NULL of UNDEF

```ruby
if My_Item.state?
  logger.info 'My_Item is not NULL nor UNDEF'
end
```

### Compare Item's State

```ruby
String_Item == 'test string'
Number_Item > 5.3
items['Number_Item'] == 10

Temperature_Item > '24 °C'
Temperature_Item > 24| '°C'
Indoor_Temperature > Outdoor_Temperature 
Indoor_Temperature > Outdoor_Temperature + '5 °C'
Indoor_Temperature - Outdoor_Temperature > '5 °C'
```

### Get the Thing Linked to an Item

```ruby
linked_thing = My_Item.thing
thing_uid = My_Item.thing.uid
```

### Get All Linked Things

An item can be linked to multiple things.

```ruby
My_Item.things.each do |thing|
  logger.info("Thing: #{thing.uid}")
end
```

## Groups

### Get the Members or All Members of a Group

```ruby
gTest.members

gTest.all_members
```

### Intersection of Two Groups

Group members work like a [Ruby array](https://ruby-doc.org/core-2.6/Array.html) 
so you can use `&` for intersection, `|` for union, and `-` for difference.

```ruby
curtains_in_family_room = gFamilyRoom.members & gCurtains.members
```

### Iterate Over Members of a Group

```ruby
gTest.each do |item|
  # process item
end

# The same:
gTest.members.each do |item|
  # process item
end

# Iterate over all members, including members of members
gTest.all_members.each do |item|
  # process item
end
```

### Filter Members of a Group

```ruby
members_that_are_on = gTest.grep(ON)
# Alternatively
members_that_are_on = gTest.select(&:on?)

# exclude state
members_that_are_not_on = gTest.grep_v(ON)
# the same as:
members_that_are_not_on = gTest.reject(&:on?)

# Filter with code:
high_temperatures = gTemperatures.select(&:state?).select { |item| item > '30 °C' }
```

### Get the First Item in a Filtered List of Group Members

Because group acts like an array, simply use Ruby's [Array#first](https://ruby-doc.org/core-2.6/Array.html#method-i-first)

```ruby
my_item = gTest.grep(ON).first
```

### Get first 5 Items from a filtered list of Group members

```ruby
my_item = gTest.grep(ON)[0, 5]
my_item = gTest.grep(ON)[0..4]
my_item = gTest.grep(ON)[0...5]
my_item = gTest.grep(ON).slice(0, 5)
```

See [Accessing elements in a Ruby array](https://ruby-doc.org/core-2.6/Array.html#class-Array-label-Accessing+Elements).

### Get a sorted list of Group members matching a condition

```ruby
sorted_items_by_battery_level = gBattery.select(&:state?) # only include non NULL / UNDEF members
                                        .select { |item| item < 20 } # select only those with low battery
                                        .sort # sort is done by comparing items, which does it by their states
```

### Get a List of Values Mapped from the Members of a Group

```ruby
battery_levels = gBattery.select(&:state?) # only include non NULL / UNDEF members
                         .sort
                         .map { |item| "#{item.label}: #{item}" } # Use item state default formatting
```

### Perform Arithmetic on Values from Members of a Group

```ruby
weekly_rainfall = gRainWeeklyForecast.sum
```

## Rules

### Create a Rule

```ruby
rule 'my first rule' do
  received_command My_Switch, to: ON
  run do
    My_Light.on
  end
end
```

This applies to file-based rules. See [Rules]({{ site.baseurl }}{% link usage/rule.md %})

### Create a Rule with One Line of Code

```ruby
received_command(My_Switch, to: ON) { My_Light.on }
```

This applies to file-based rules. See [Terse Rules]({{ site.baseurl }}{% link usage/rule.md %}#terse-rules)

### Create a Rule in the Main UI

See [Creating Rules in the UI]({{ site.baseurl }}{% link usage/ui-rules.md %})

### Get the Triggering Item

```ruby
event.item
```

### Get the Triggering Item's Name

```ruby
event.item.name
```

### Get the Triggering Item's Label

```ruby
event.item.label
```

### Get the Triggering Item's State

```ruby
event.state
```

or

```ruby
event.item.state
```

The item's state can also be obtained by accessing the triggering item itself.

```ruby
# Item can be compared against their state
if event.item == ON
  # do something
end
# or
if event.item.on?
  # do something
end
```

### Get the Triggering Item's Previous State

```ruby
event.was
```

Example:

```ruby
if event.was.on?
  # do something
end
```

### Compare Triggering Item's State Against Previous State

```ruby
event.state > event.was
```

### Get the Received Command

```ruby
event.command
```

Example:

```ruby
if event.command.on?
  # do something
end
```

### Create a Member-of-Group Trigger

```ruby
rule 'Trigger by Member of' do
  changed gGroupName.members
  run do |event|
    logger.info "Triggered item: #{event.item.name}"
  end
end
```

### Run a Rule on Start Up

```ruby
rule 'initialize things' do
  on_start # This also triggers whenever the script (re)loads
  run { logger.info 'Here we go!' }
end
```

### Use Multiple Triggers

```ruby
rule 'multiple triggers' do
  changed Switch1, to: ON
  changed Switch2, to: ON
  run { |event| logger.info "Switch: #{event.item.name} changed to: #{event.item}" }
end
```

When the trigger conditions are the same, the triggers can be combined

```ruby
rule 'multiple triggers' do
  changed Switch1, Switch2, to: ON
  run { |event| logger.info "Switch: #{event.item.name} changed to: #{event.item}" }
end
```

### Use Multiple Conditions

```ruby
rule 'multiple conditions' do
  changed Button_Action, to: ['single', 'double']
  run { |event| logger.info "Action: #{event.item}" }
end
```

### Create a Simple Cron Rule

```ruby
rule 'run every day' do
  every :day, at: '2:35pm'
  run { Amazon_Echo_TTS << "It's time to pick up the kids!" }
end
```

```ruby
rule 'run every 5 mins' do
  every 5.minutes
  run { logger.info 'openHAB is awesome' }
end
```

```ruby
rule 'Anniversary Reminder' do
  every '10-15' # Trigger on 15th of October at midnight
  run do
    things['mail:smtp:mymailthing'].sendMail('me@example.com', 'Anniversary Reminder!', 'Today is your anniversary!') 
  end
end
```

See [Every]({{ site.baseurl }}{% link usage/triggers/every.md %})

### Create a Complex Cron Rule

```ruby
rule 'cron rule' do
  cron '0 0,15 15-19 L * ?'
  run { logger.info 'Cron run' }
end
```

or an easier syntax:

```ruby
rule 'cron rule' do
  cron second: 0, minute: '0,15', hour: '15-19', dom: 'L'
  run { logger.info 'Cron run' }
end
```

See [Cron]({{ site.baseurl }}{% link usage/triggers/cron.md %})

### Use Rule Guards

```ruby
rule 'motion sensor' do
  updated Motion_Sensor, to: ON
  only_if Sensor_Enable # Run rule only if Sensor_Enable item is ON
  not_if { Sun_Elevation.positive? } # and not while the sun is up
  run { LightItem.on }
end
```

See [Guards]({{ site.baseurl }}{% link usage/guards/index.md %})

### Restrict Rule Executions to Certain Time of Day

```ruby
rule 'doorbell' do
  updated DoorBell_Button, to: 'single'
  between '6am'..'8:30pm'
  run { play_sound 'doorbell_chime.mp3' }
end
```

### Stop a Rule if the Triggering Item’s State is NULL or UNDEF

Use `next` within a file-based rule, because it's in a block:

```ruby
next unless event.item.state?
```

Use `return` within a UI rule:

```ruby
return unless event.item.state?
```

### Suppress Item State Flapping

Only execute a rule when an item state changed and stayed the same for a period of time. This method 
can only be done using a file-based rule.

```ruby
rule 'Announce pool temperature' do
  changed Pool_Temperature, for: 10.minutes # Only when temp is stable for at least 10 minutes
  only_if Pool_Heater # And only when the pool heater is running
  run { say "The pool temperature is now #{Pool_Temperature}" }
end
```

### Add a Pause / Sleep / Delay

```ruby
sleep 1.5 # sleep for 1.5 seconds
```

See Ruby docs on [sleep](https://ruby-doc.org/core-2.6/Kernel.html#method-i-sleep)

`sleep` should be avoided if possible. A [delay]({{ site.baseurl }}{% link usage/execution/delay.md %})
can be inserted in between two execution blocks to achieve the same result. This delay is implemented with a timer.
This is available only on file-based rules.

```ruby
rule 'delay something' do
  on_start
  run { logger.info 'This will run immediately' }
  delay 10.seconds
  run { logger.info 'This will run 10 seconds after' }
end
```

Alternatively a [timer]({{ site.baseurl }}{% link usage/misc/timers.md %}) can be used in 
either a file-based rule or in a UI based rule:

```ruby
rule 'delay something' do
  on_start
  run do
    logger.info 'This will run immediately' 
    after(10.seconds) do
      logger.info 'This will run 10 seconds after'
    end
  end
end
```



## Things

### Get Thing Status

```ruby
things['lgwebos:WebOSTV:main-tv'].status
```

### Check if Thing is Online

```ruby
things['lgwebos:WebOSTV:main-tv'].online?
```

or

```ruby
things['lgwebos:WebOSTV:main-tv'].status == ThingStatus::ONLINE
```

### Enable/Disable a Thing

```ruby
thing_manager = OpenHAB::Core::OSGI.service('org.openhab.core.thing.ThingManager')

thing = things['lgwebos:WebOSTV:main-tv']

thing_manager.set_enabled(thing.uid, false)
logger.info "TV enabled: #{thing.enabled?}"

thing_manager.set_enabled(thing.uid, true)
logger.info "TV enabled: #{thing.enabled?}"
```

## Timers

### Create a Timer

```ruby
after 3.minutes do
  My_Light.on
end
```

See [Timers]({{ site.baseurl }}{% link usage/misc/timers.md %})

### Reschedule a Timer

A timer can be rescheduled inside the timer body

```ruby
after 3.minutes do |timer|
  My_Light.on
  timer.reschedule # This will reschedule it for the same initial duration, i.e. 3 minutes in this case
end
```

Or it can be rescheduled from outside the timer

```ruby
my_timer = after 3.minutes do
  My_Light.on
end

my_timer.reschedule # Use the same initial duration
```

It can be rescheduled to a different duration

```ruby
after 3.minutes do |timer|
  My_Light.on
  timer.reschedule 1.minute
end
```

### Manage Multiple Timers

Multiple timers can be managed in the traditional way by storing the timer objects in a hash

```ruby
@timers = {}

rule 'a timer for each group member' do
  received_command gOutdoorLights.members do
  run do |event|
    if @timers[event.item]
      @timers[event.item].reschedule 
    else
      @timers[event.item] = after 3.minutes do # Use the triggering item as the timer ID
        event.item.off
        @timers.delete(event.item)
      end
    end
  end
end
```

However, [a built in mechanism]({{ site.baseurl }}{% link usage/misc/timers.md %}#reentrant-timers) is available to 
help manage multiple timers. This is done using timer IDs. The following rule automatically finds and reschedules 
the timer matching the same ID, which corresponds to each group member.

```ruby
rule 'a timer for each group member' do
  received_command gOutdoorLights.members do
  run do |event|
    after 3.minutes, id: event.item do # Use the triggering item as the timer ID
      event.item.off
    end
  end
end
```

Furthermore, you can manipulate the managed timers using the built-in `timers[]` hash.

```ruby
# timers[] is a special hash to access the timers created with an id
# Note here we use Ruby's safe navigation operator in case the timer
# no longer exists, in which case timers[id] returns nil
rule 'cancel all timers' do
  received_command Cancel_All_Timers, to: ON # Send a command to this item to cancel all timers
  run do
    gOutdoorLights.each do |item_as_timer_id|
      timers[item_as_timer_id]&.cancel_all 
    end
  end
end

rule 'reschedule all timers' do
  received_command Reschedule_All_Timers, to: ON # Send a command to this item to restart all timers
  run do
    gOutdoorLights.each do |item_as_timer_id|
      timers[item_as_timer_id]&.each(&:reschedule) # Note timers[] returns a hash of timers
    end
  end
end
```


 
## Use Metadata

```ruby
metadata = My_Item.meta['namespace'].value
```

See [Metadata]({{ site.baseurl }}{% link usage/misc/metadata.md %})

## Use Persistence

```ruby
daily_max = My_Item.maximum_since(24.hours)
```

See [Persistence]({{ site.baseurl }}{% link usage/misc/persistence.md %})

## Use Logging

```ruby
logger.info("My Item's state is: #{My_Item}")
```

See [Logging]({{ site.baseurl }}{% link usage/misc/logging.md %})

## Use Actions

See [Actions]({{ site.baseurl }}{% link usage/misc/actions.md %})

### Publish an MQTT Message

```ruby
things['mqtt:broker:mybroker'].publishMQTT('topic/name', 'payload')
```

### Send an Email

```ruby
things['mail:smtp:mymailthing'].sendMail('me@example.com', 'Subject', 'message body')
```

### Play Sound Through the Default Audio Sink

```ruby
play_sound 'sound_file.mp3'
```

### Execute a Command

```ruby
Exec.executeCommandLine('/path/to/program')
```

## Date/Time

### Use ZonedDateTime

Prior to OpenHAB 3.3, ZonedDateTime needs to be imported before use. From OpenHAB 3.3+ the following classes are available without having to import them manually:

* `ZonedDateTime`
* `ZoneId`
* `Duration`
* `ChronoUnit`

```ruby
java_import java.time.ZonedDateTime # Not needed on OpenHAB 3.3+

ZonedDateTime.now.plus_minutes(30)
```

### Convert ZonedDateTime to Ruby Time

```ruby
Time.at(ZonedDateTime.now.to_epoch_second)
```

### Convert Ruby Time to ZonedDateTime

```ruby
ruby_time = Time.now
ruby_time.to_java(ZonedDateTime)
```

### Work with Time of Day

```ruby
if TimeOfDay.now > '7am'
  logger.info 'Wake up!'
end
```

```ruby
# The range can cross midnight
if TimeOfDay.now.between?('10pm'..'5am')
  logger.info 'Sleep time'
end
```

See [TimeOfDay]({{ site.baseurl }}{% link usage/misc/time_of_day.md %})

### Work with MonthDay

```ruby
if MonthDay.now == '02-14'
  logger.info "Happy Valentine's Day!"
end
```

See [MonthDay]({{ site.baseurl }}{% link usage/misc/month_day.md %})

## Ruby

### Install Additional Gems

```ruby
gemfile do
  source 'https://rubygems.org'
  gem 'httparty'
end
```

See [Inline Bundler]({{ site.baseurl }}{% link usage/misc/gems.md %})

### Use Shared Library

See [Shared Code]({{ site.baseurl }}{% link usage/misc/shared_code.md %})

## Miscellaneous

### Get the UID of a Rule 

This applies to file-based rules:

```ruby
rule_obj = rule 'my rule name' do
  received_command My_Item
  run do
    # rule code here
  end
end

rule_uid = rule_obj.uid
```

### Get the UID of a Rule by Name

```ruby
rule_uid = OpenHAB::Core.rule_registry.all.select { |rule| rule.name == 'This is the name of my rule' }.first.uid
```

### Enable or Disable a Rule by UID

```ruby
rule_manager = OpenHAB::Core::OSGI.service('org.openhab.core.automation.RuleManager')
rule_manager.set_enabled(rule_uid, true) # enable rule
rule_manager.set_enabled(rule_uid, false) # disable rule
```

### Run a rule by UID

```ruby
rule_manager = OpenHAB::Core::OSGI.service('org.openhab.core.automation.RuleManager')
rule_manager.run_now(rule_uid)
```

### Use a Java Class

```ruby
java_import java.time.format.DateTimeFormatter

formatter = DateTimeFormatter.of_pattern('yyyy MM dd')
```

```ruby
formatter = Java::JavaTimeFormat::DateTimeFormatter.of_pattern('yyyy MM dd')
```

See: [Calling Java from JRuby](https://github.com/jruby/jruby/wiki/CallingJavaFromJRuby)
