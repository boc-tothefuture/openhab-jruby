# JRuby 

## Design points
- Create an intuitive method of defining rules and automation
	- Rule language should "flow" in a way that you can read the rules out loud
- Abstract away complexities of OpenHAB (Timers, Item.state vs Item)
- Enable all the power of Ruby and OpenHAB
- Create a 'Frictionless' experience for building automation
- The common, yet tricky tasks are abstracted and made easy. e.g. Running a rule between only certain hours of the day
- Tested
	- Designed and tested using (Behavior Driven Development)[https://en.wikipedia.org/wiki/Behavior-driven_development] with (Cucumber)[https://cucumber.io/]
- Extensible
	- Anyone should be able to customize and add/remove core language features
- Easy access to the Ruby ecosystem in rules through ruby gems. 

## Why Ruby?
- It was designed for programmer productivity with the idea that programming should be fun for programmers.
- It emphasizes the necessity for software to be understood by humans first and computers second.
- For me, automation is a hobby, I want to enjoy writing automation not fight compilers.
- Rich ecosystem of tools, including things like Rubocop to help developers create good code and cucumber to test the libraries
-  Ruby is really good at letting one express yourself and creating a DSL within ruby  to make expression easier.


## Design Decisions / Core Language Features:
- All items, groups and things are automatically available, no need to "getItem", etc.
- *channels are available as "dot notation" on things*
- List of items are available as "items" and do not include groups
- List of groups are available as "groups"


## Prerequisites
1. OpenHAB 3
2. Install the JRuby Scripting Language Addon
3. Install scripting library
4. Place Ruby files in `conf/automation/jsr223/ruby/personal/` subdirectory
5. Place `require 'OpenHAB'` at the top of any Ruby based rules file.

## Installation



## RubyGems
[Bundler](https://bundler.io/) is integrated, enabling any [Rubygem](https://rubygems.org/) compatible with JRuby to be used within rules. This permits easy access to the vast ecosystem libraries within the ruby community.  It would also create easy reuse of automation libraries within the OpenHAB community, any library published as a gem can be easily pulled into rules. 


##  Rule Syntax
```
require 'OpenHAB'

rule 'name' do
   <zero or more triggers>
   run do
      <automation code goes here>
   end
   <zero or more guards>
end
```

### All of the properties that are available to the rule resource are

| Property  | Type                                         | Single/Multiple | Options                               | Default | Description                                                                 | Examples                                                                                                                                       |
| --------- | -------------------------------------------- | --------------- | ------------------------------------- | ------- | --------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| every     | Symbol or Duration                           | Multiple        | at: String or TimeOfDay               |         | When to execute rule                                                        | Symbol (:second, :minute, :hour, :day, :week, :month, :year, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday) or duration (5.minutes, 20.seconds, 14.hours), at: '5:15' or TimeOfDay(h:5, m:15) | 
| cron      | String                                       | Multiple        |                                       |         | OpenHAB Style Cron Expression                                               | '* * * * * * ?'                                                                                                                                |
| changed   | Item or Item Array[] or Group or Group.items | Multiple        | from: State, to: State, for: Duration |         | Execute rule on item state change                                           | BedroomLightSwitch from: OFF to ON                                                                                                             |
| *updated* | Item or Item Array[] or Group or Group.items | Multiple        |                                       |         | Execute rule on item update                                                 | BedroomLightSwitch                                                                                                                             |
| *command* | Item or Item Array[] or Group or Group.items | Multiple        | command:                              |         | Execute rule on item command                                                | BedroomLightSwitch command: ON                                                                                                                 |
| *channel* | Channel                                      | Multiple        | event:                                |         | Execute rule on channel trigger                                             | astro_sun_home.rise_event, event: 'START'                                                                                                      |
| on_start  | Boolean                                      | Single          |                                       | false   | Execute rule on system start                                                | on_start                                                                                                                                       |
| run       | Block passed event                           | Multiple        |                                       |         | Code to execute on rule trigger                                             |                                                                                                                                                |
| triggered | Block passed item                            | Multiple        |                                       |         | Code with triggering item to execute on rule trigger                        |                                                                                                                                                |
| delay     | Duration                                     | Multiple        |                                       |         | Duration to wait between or after run blocks                                | delay 5.seconds                                                                                                                                |
| between   | Range of TimeOfDay or String Objects         | Single          |                                       |         | Only execute rule if current time is between supplied time ranges           | '6:05'..'14:05:05' (Include end) or '6:05'...'14:05:05' (Excludes end second) or TimeOfDay.new(h:6,m:5)..TimeOfDay.new(h:14,m:15,s:5)          |
| only_if   | Item or Item Array, or Block                 | Multiple        |                                       |         | Only execute rule if all supplied items are "On" and/or block returns true  | BedroomLightSwitch, BackyardLightSwitch or {BedroomLightSwitch.state == ON}                                                                    |
| not_if    | Item or Item Array, or Block                 | Multiple        |                                       |         | Do **NOT** execute rule if any of the supplied items or blocks returns true | BedroomLightSwitch                                                                                                                             |
| enabled   | Boolean                                      | Single          |                                       | true    | Enable or disable the rule from executing                                   |                                                                                                                                                |

*Not yet developed - syntax likely to change*
		
#### Property Values

##### Every

| Value             | Description                              | Example    |     |     |
| ----------------- | ---------------------------------------- | ---------- | --- | --- |
| :second           | Execute rule every second                | :second    |     |     |
| :minute           | Execute rule very minute                 | :minute    |     |     |
| :hour             | Execute rule every hour                  | :hour      |     |     |
| :day              | Execute rule every day                   | :day       |     |     |
| :week             | Execute rule every week                  | :week      |     |     |
| :month            | Execute rule every month                 | :month     |     |     |
| :year             | Execute rule one a year                  | :year      |     |     |
| :monday           | Execute rule every Monday at midnight    | :monday    |     |     |
| :tuesday          | Execute rule every Tuesday at midnight   | :tuesday   |     |     |
| :wednesday        | Execute rule every Wednesday at midnight | :wednesday |     |     |
| :thursday         | Execute rule every Thursday at midnight  | :thursday  |     |     |
| :friday           | Execute rule every Friday at midnight    | :friday    |     |     |
| :saturday         | Execute rule every Saturday at midnight  | :saturday  |     |     |
| :sunday           | Execute rule every Sunday at midnight    | :sunday    |     |     |
| [Integer].seconds | Execute a rule every X seconds           | 5.seconds  |     |     |
| [Integer].minutes | Execute rule every X minutes             | 3.minutes  |     |     |
| [Integer].hours   | Execute rule every X minutes             | 10.hours   |     |     |

| Option | Description                                                                                          | Example                                        |
| ------ | ---------------------------------------------------------------------------------------------------- | ---------------------------------------------- |
| :at    | Limit the execution to specific times of day. The value can either be a String or a TimeOfDay object | at: '16:45' or at: TimeOfDay.new(h: 16, m: 45) | 


##### Examples

```
rule 'Log an entry at 11:21' do
  every :day, at: '11:21'
  run { logger.info("Rule #{name} run at #{TimeOfDay.now}") }
end
```
Which is the same as
```
rule 'Log an entry at 11:21' do
  every :day, at: TimeOfDay.new(h: 11, m: 21)
  run { logger.info("Rule #{name} run at #{TimeOfDay.now}") }
end
```


```
rule 'Log an entry Wednesdays at 11:21' do
  every :wednesday, at: '11:21'
  run { logger.info("Rule #{name} run at #{TimeOfDay.now}") }
end
```



##### Changed
| Value | Description                                            | Example         |
| ----- | ------------------------------------------------------ | --------------- |
| :from | Only execute rule if previous state matches from state | :from OFF       |
| :to   | Only execute rule if new state matches from state      | :to ON          |
| :for  | Only execute rule if value stays changed for duration  | :for 10.seconds | 

The for parameter provides a method of only executing the rule if the value is changed for a specific duration.  This provides a built-in method of delaying rule execution with the need to create dummy objects with the expire binding or make or manage your own times. 

For example, the code in [this design pattern](https://community.openhab.org/t/design-pattern-expire-binding-based-timers/32634) becomes (with no need to create the dummy object):
```
rule "Execute rule when item is changed for specified duration" do
  changed Alarm_Mode, for: 20.seconds
  run { logger.info("Alarm Mode Updated")}
end
```

You can optionally provide from and to states to restrict the cases in which the rule executes:
```
rule 'Execute rule when item is changed to specific number, from specific number, for specified duration' do
  changed Alarm_Mode, from: 8, to: 14, for: 12.seconds
  run { logger.info("Alarm Mode Updated")}
end
```

Real world example:
```
rule 'Log (or notify) when an exterior door is left open for more than 5 minutes' do
  changed ExteriorDoors, to: OPEN, for: 5.minutes
  triggered {|door| logger.info("#{door} has been left open!")}
end
```


#### Run
The run property is the automation code that is run when a rule is triggered.  This property accepts a block of code and executes it.  The block is automatically passed an event object which can be used to access multiple properties about the triggering event.  The code for the automation can be entirely within the run block can call methods defined in the ruby script.

```
run { |event| }

or

run do |event| 

end


```

```

```


##### Event Properties
| Property | Description                      |
| -------- | -------------------------------- |
| item     | Triggering item                  |
| state    | Changed state of triggering item |
| last     | Last state of triggering item    | 


### Execution Blocks

#### Triggered
This property is the same as the run property except rather than passing an event object to the automation block the triggered item is passed. This enables optimizations for simple cases and supports ruby's [pretzel colon `&:` operator.](https://medium.com/@dcjones/the-pretzel-colon-75df46dde0c7) 

##### Examples

```
rule 'Turn off any switch that changes' do
  changed Switches.items
  triggered(&:off)
end
```



#### Delay
The delay property is a non thread-blocking element that is executed after, before, or between run blocks. 

```
rule 'Dim a switch on system startup over 100 seconds' do
   on_start
   100.times do
     run { DimmerSwitch.dim }
     delay 1.second
   end
 end

```

### Guards

#### Between
Only runs the rule if the current time is in the provided range

```
rule 'Log an entry if started between 3:30:04 and midnight using strings' do
  on_start
  run { logger.info ("Started at #{TimeOfDay.now}")}
  between '3:30:04'..MIDNIGHT
end
```

or

```
rule 'Log an entry if started between 3:30:04 and midnight using TimeOfDay objects' do
  on_start
  run { logger.info ("Started at #{TimeOfDay.now}")}
  between TimeOfDay.new(h: 3, m: 30, s: 4)..TimeOfDay.midnight
end
```


### Items
Items can be directly accessed, compared, etc, without any special accessors. You may use the Item name anywhere within the code and it will automatically be loaded.

All items can be accessed as an enumerable the `items` method. 

| Method             | Description                                                                    |
| ------------------ | ------------------------------------------------------------------------------ |
| []                 | Get a specific item by name, this syntax can be used to dynamically load items | 
| enumerable methods | All methods [here](https://ruby-doc.org/core-2.5.0/Enumerable.html)            |

#### Examples

Item Definition
```
Dimmer DimmerTest "Test Dimmer"
Switch SwitchTest "Test Switch"

```

```
logger.info("Item Count: #{items.count}")  # Item Count: 2
logger.info("Items: #{items.sort_by{|item| item.name}.join(', ')}")  #Items: Test Dimmer, Test Switch' 
```

```
rule 'Use dynamic item lookup to increase related dimmer brightness when switch is turned on' do
  changed SwitchTest, to: ON
  triggered { |item| items[item.name.gsub('Switch','Dimmer')].brighten(10) }
end
```


All methods of the OpenHAB item are available plus the additional methods described below.


| Method | Description                             | Example                    |     |     |
| ------ | --------------------------------------- | -------------------------- | --- | --- |
| <<     | sends command to item, alias for state= | `VirtualSwich << ON`       |     |     |
| state= | sends command to item                   | `VirtualSwitch.state = ON` |     |     |
|        |                                         |                            |     |     |




Each item type has methods added to it to make it flow naturally within the a ruby context.

#### SwitchItem
This class is aliased to **Switch** so you can compare compare item types using ` item.is_a? Switch or grep(Switch)`

| Method  | Description                               | Example                                         |
| ------- | ----------------------------------------- | ----------------------------------------------- |
| active? | Item is not undefined, not null and is ON | `puts "#{item.name} is active" if item.active?` |
| on      | Send command to turn item ON              | `item.on`                                       |
| off     | Send command to turn item OFF             | `item.off`                                      |
| on?     | Returns true if item state == ON          | `puts "#{item.name} is on." if item.on?`        |
| off?    | Returns true if item state == OFF         | `puts "#{item.name} is off." if item.off?`      |

```
 # Invert all switches
 items.grep(Switch)
      .each { |item| if item.off? then item.on else item.off end}
```



#### DimmerItem
This class is aliased to **Dimmer** so you can compare compare item types using ` item.is_a? Dimmer or grep(Dimmer)`

| Method       | Parameters         | Description                               | Example                                         |
| ------------ | ------------------ | ----------------------------------------- | ----------------------------------------------- |
| active?      |                    | Item is not undefined, not null and is ON | `puts "#{item.name} is active" if item.active?` |
| on           |                    | Send command to turn item ON              | `item.on`                                       |
| off          |                    | Send command to turn item OFF             | `item.off`                                      |
| on?          |                    | Returns true if item state == ON          | `puts "#{item.name} is on." if item.on?`        |
| off?         |                    | Returns true if item state == OFF         | `puts "#{item.name} is off." if item.off?`      |
| dim, -=      | amount (default 1) | Dim the switch the specified amount      | `DimmerSwitch.dim` or `DimmerSwitch -= 5`       |
| brighten, += | amount (default 1) | Brighten the switch the specified amount | `DimmerSwitch.brighten` or `DimmerSwitch += 5`  |

##### Examples
```
rule 'Dim a switch on system startup over 100 seconds' do
  on_start
  100.times do
    run { DimmerSwitch.dim }
    delay 1.second
  end
 end

```

```
rule 'Dim a switch on system startup by 5, pausing every second' do
   on_start
   100.step(-5, 0) do | level |
     run { DimmerSwitch << level }
     delay 1.second
   end
 end
```


```
 rule 'Turn off any dimmers curently on at midnight' do
   every :day
   run do
     items.grep(Dimmer)
          .select(&:on?)
          .each(&:off)
     end
 end
```

```
 rule 'Turn off any dimmers set to less than 50 at midnight' do
   every :day
   run do
     items.grep(Dimmer)
          .grep(1...50)
          .each(&:off)
     end
 end
```



#### Contact Item

| Method  | Description                               | Example                                    |
| ------- | ----------------------------------------- | ------------------------------------------ |
| active? | Item is not undefined, not null and is ON | `puts "#{item} is active" if item.active?` |
| open?   | Returns true if item state == OPEN        | `puts "#{item} is closed." if item.open?`  |
| closed? | Returns true if item state == CLOSED      | `puts "#{item} is off." if item.closed`    |


##### Examples

```
rule 'Log state of all doors on system startup' do
  on_start
  run do
    Doors.each do |door|
      case door
      when OPEN then logger.info("#{door} is Open")
      when CLOSED then logger.info("#{door} is Open")
      else logger.info("#{door} is not initialized")
      end
    end
  end
end

```



### Groups

A group can be accessed directly by name, to access all groups use the `groups` method. 


#### Group Methods

| Method             | Description                                                                                     |
| ------------------ | ----------------------------------------------------------------------------------------------- |
| group              | Access Group Item                                                                               |
| items              | Used to inform a rule that you want it to operate on the items in the group (see example below) |
| groups             | Direct subgroups of this group                                                                                                |
| set methods        | All methods [here](https://ruby-doc.org/stdlib-2.5.0/libdoc/set/rdoc/Set.html)                  |
| enumerable methods | All methods [here](https://ruby-doc.org/core-2.5.0/Enumerable.html)                             |


#### Examples

Given the following

```
Group House
// Location perspective
Group GroundFloor  (House)
Group Livingroom   (GroundFloor)
// Functional perspective
Group Sensors      (House)
Group Temperatures (Sensors)

Number Livingroom_Temperature "Living Room temperature" (Livingroom, Temperatures)
Number Bedroom_Temp "Bedroom temperature" (GroundFloor, Temperatures)
Number Den_Temp "Den temperature" (GroundFloor, Temperatures)
```

The following are log lines and the output after the comment

```
#Operate on items in a group using enumerable methods
logger.info("Total Temperatures: #{Temperatures.count}")     #Total Temperatures: 3'
logger.info("Temperatures: #{House.sort_by{|item| item.label}.join(', ')}") #Temperatures: Bedroom temperature, Den temperature, Living Room temperature' 

#Access to the group object via the 'group' method
logger.info("Group: #{Temperatures.group.name}" # Group: Temperatures'

#Operates on items in nested groups using enumerable methods
logger.info("House Count: #{House.count}")           # House Count: 3
logger.info("Items: #{House.sort_by{|item| item.label}.join(', ')}")  # Items: Bedroom temperature, Den temperature, Living Room temperature

#Access to sub groups using the 'groups' method
logger.info("House Sub Groups: #{House.groups.count}")  # House Sub Groups: 2
logger.info("Groups: #{House.groups.sort_by{|item| item.label}.join(', ')}")  # Groups: GroundFloor, Sensors


```


```
rule 'Turn off any switch that changes' do
  changed Switches.items
  triggered &:off
end
```


### Logging
Logging is available everywhere through the logger object.  The name of the rule file is automatically appended to the logger name. Pending [merge](https://github.com/openhab/openhab-core/pull/1885) into the core.

```
logger.trace('Test logging at trace') # 2020-12-03 18:05:20.903 [TRACE] [jsr223.jruby.log_test               ] - Test logging at trace
logger.debug('Test logging at debug') # 2020-12-03 18:05:32.020 [DEBUG] [jsr223.jruby.log_test               ] - Test logging at debug
logger.warn('Test logging at warn') # 2020-12-03 18:05:41.817 [WARN ] [jsr223.jruby.log_test               ] - Test logging at warn
logger.info('Test logging at info') # Test logging at info
logger.error('Test logging at error') # 2020-12-03 18:06:02.021 [ERROR] [jsr223.jruby.log_test               ] - Test logging at error
```

### Ruby Gems
Gems are available using the [inline bundler syntax](https://bundler.io/guides/bundler_in_a_single_file_ruby_script.html). The require statement can be omitted. 

```
gemfile do
  source 'https://rubygems.org'
   gem 'json', require: false
   gem 'nap', '1.1.0', require: 'rest'
end

logger.info("The nap gem is at version #{REST::VERSION}")     
```



## Examples

### Log "Rule *name* executed" an entry every minute

```
rule 'Simple' do
  every :minute
  run { logger.info "Rule #{name} executed" }
end

```


### The rule definition itself is just ruby code

Meaning you can use code itself to generate your rules*

```
rule 'Log whenever a Virtual Switch Changes' do
  items.select { |item| item.is_a? Switch }
       .select { |item| item.label&.include? 'Virtual' }
       .each do |item|
         changed item
       end

  run { |event| logger.info "#{event.item} changed from #{event.last} to #{event.state}" }
end
```

Which is the same as
```
virtual_switches = items.select { |item| item.is_a? Switch }
                        .select { |item| item.label&.include? 'Virtual' }

rule 'Log whenever a Virtual Switch Changes 2' do
  changed virtual_switches
  run { |event| logger.info "#{event.item} changed from #{event.last} to #{event.state} 2" }
end
```

This will accomplish the same thing, but create a new rule for each virtual switch*
```
virtual_switches = items.select { |item| item.is_a? Switch }
                        .select { |item| item.label&.include? 'Virtual' }

virtual_switches.each do |switch|
  rule "Log whenever a #{switch.label} Changes" do
    changed switch
    run { |event| logger.info "#{event.item} changed from #{event.last} to #{event.state} 2" }
  end
end
```

* Take care when doing this as the the items/groups are processed when the rules file is processed, meaning that new items/groups will not automatically generate new rules. 



##### Conversion Examples

DSL

```
rule 'Snap Fan to preset percentages'
when Member of CeilingFans changed
then
  val fan = triggeringItem
  val name = String.join(" ", fan.name.replace("LoadLevelStatus","").split("(?<!^)(?=[A-Z])"))
  logInfo("Fan", "Ceiling fan group rule triggered for {}, value {}", name,fan.state)
  switch fan {
  	case fan.state >0 && fan.state < 25 : {
  		logInfo("Fan", "Snapping {} to 25%", name)
  		sendCommand(fan, 25)
  	}
  	case fan.state > 25 && fan.state < 66 : {
  		logInfo("Fan", "Snapping {} to 66%", name)
  		sendCommand(fan, 66)
  	}
  	case fan.state > 66 && fan.state < 100 : {
  		logInfo("Fan", "Snapping {} to 100%", name)
  		sendCommand(fan, 100)
  	}
	default: {
  		logInfo("Fan", "{} set to snapped percentage, no action taken", name)
	}
  }
end
```

Ruby
```
rule 'Snap Fan to preset percentages' do
  changed(*CeilingFans)
  triggered do |item|
    snapped = case item
              when 0...25 then 25
              when 26...66 then 66
              when 67...100 then 100
              end
    if snapped
       logger.info("Snapping fan #{item} to #{snapped}")
      item << snapped
    else
      logger.info("#{item} set to snapped percentage, no action taken.")
    end
  end
end
```




## To Do
1. Internal restructuring of modules/classes
2. Rubocop fixes
3. Add support for missing rule operations
4. Add support for missing item types
5. Add support for missing operations (update, etc)
6. Logging normalization and cleanup
7. Add support for actions (including notify)
8. Add support for transformations
9. Modify based on feedback from the community
10. Provide more conversions examples as more missing elements are added to the language