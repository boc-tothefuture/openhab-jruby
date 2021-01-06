# JRuby OpenHAB Scripting

## Design points
- Create an intuitive method of defining rules and automation
	- Rule language should "flow" in a way that you can read the rules out loud
- Abstract away complexities of OpenHAB (Timers, Item.state vs Item)
- Enable all the power of Ruby and OpenHAB
- Create a Frictionless experience for building automation
- The common, yet tricky tasks are abstracted and made easy. e.g. Running a rule between only certain hours of the day
- Tested
	- Designed and tested using [Behavior Driven Development](https://en.wikipedia.org/wiki/Behavior-driven_development) with [Cucumber](https://cucumber.io/)
	- Current tests are [here](https://github.com/boc-tothefuture/openhab-jruby/tree/main/features)  Reviewing them is a great way to explore the language features
- Extensible
	- Anyone should be able to customize and add/remove core language features
- Easy access to the Ruby ecosystem in rules through ruby gems. 

## Why Ruby?
- Ruby is designed for programmer productivity with the idea that programming should be fun for programmers.
- Ruby emphasizes the necessity for software to be understood by humans first and computers second.
- For me, automation is a hobby, I want to enjoy writing automation not fight compilers and interpreters 
- Rich ecosystem of tools, including things like Rubocop to help developers create good code and cucumber to test the libraries
-  Ruby is really good at letting one express intent and creating a DSL within ruby to make that expression easier.


## Source
JRuby Scripting OpenHAB is GitHub repo is [here](https://github.com/boc-tothefuture/openhab-jruby).  Code is under the eclipse v2 license.

Please feel free to open issues, PRs welcome! 



## Prerequisites
1. OpenHAB 3
2. The JRuby Scripting Language Addon
3. This scripting library

## State
This is an alpha and syntax and all elements are subject to change as the library evolves.

## Installation
1. Install the latest Jruby Scripting Language Addon from [here](https://github.com/boc-tothefuture/openhab-jruby/releases/) to the folder `<openhab_base_dir>/addons/`
2. Create directory for JRuby Libraries `<openhab_base_dir>/conf/automation/lib/ruby/lib`
3. Create directory for Ruby Gems `<openhab_base_dir>/conf/automation/lib/ruby/gem_home`
4. Download latest JRuby Libraries from [here](https://github.com/boc-tothefuture/openhab-jruby/releases/)
5. Install libraries in `<openhab_base_dir>/conf/automation/lib/ruby/lib`
6. Update OpenHAB start.sh with the following environment variables so that the library can be loaded and gems can be installed
```
export RUBYLIB=<openhab_base_dir>/conf/automation/lib/ruby/lib
export GEM_HOME=<openhab_base_dir>/conf/automation/lib/ruby/gem_home
```
7. Restart OpenHAB



## Rules Requirements
1. Place Ruby rules files in `ruby/personal/` subdirectory for OpenHAB scripted automation.  See [OpenHAB documentation](https://www.openhab.org/docs/configuration/jsr223.html#script-locations) for parent directory location.
2. Put `require 'openhab'` at the top of any Ruby based rules file.


##  Rule Syntax
```ruby
require 'openhab'

rule 'name' do
   <zero or more triggers>
   <zero or more execution blocks>
   <zero or more guards>
end
```

### All of the properties that are available to the rule resource are

| Property         | Type                                                                    | Last/Multiple | Options                               | Default | Description                                                                 | Examples                                                                                                                                                                                                              |
| ---------------- | ----------------------------------------------------------------------- | ------------- | ------------------------------------- | ------- | --------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| every            | Symbol or Duration                                                      | Multiple      | at: String or TimeOfDay               |         | When to execute rule                                                        | Symbol (:second, :minute, :hour, :day, :week, :month, :year, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday) or duration (5.minutes, 20.seconds, 14.hours), at: '5:15' or TimeOfDay(h:5, m:15) |
| cron             | String                                                                  | Multiple      |                                       |         | OpenHAB Style Cron Expression                                               | '* * * * * * ?'                                                                                                                                                                                                       |
| changed          | Item or Item Array[] or Group or Group.items or Thing or Thing Array [] | Multiple      | from: State, to: State, for: Duration |         | Execute rule on item state change                                           | BedroomLightSwitch, from: OFF to ON                                                                                                                                                                                   |
| updated          | Item or Item Array[] or Group or Group.items or Thing or Thing Array [] | Multiple      | to: State                             |         | Execute rule on item update                                                 | BedroomLightSwitch, to: ON                                                                                                                                                                                            |
| received_command | Item or Item Array[] or Group or Group.items                            | Multiple      | command:                              |         | Execute rule on item command                                                | BedroomLightSwitch command: ON                                                                                                                                                                                        |
| channel          | Channel                                                                 | Multiple      | triggered:                            |         | Execute rule on channel trigger                                             | `'astro:sun:home:rise#event', triggered: 'START'`                                                                                                                                                                     |
| on_start         | Boolean                                                                 | Single        |                                       | false   | Execute rule on system start                                                | on_start                                                                                                                                                                                                              |
| run              | Block passed event                                                      | Multiple      |                                       |         | Code to execute on rule trigger                                             |                                                                                                                                                                                                                       |
| triggered        | Block passed item                                                       | Multiple      |                                       |         | Code with triggering item to execute on rule trigger                        |                                                                                                                                                                                                                       |
| delay            | Duration                                                                | Multiple      |                                       |         | Duration to wait between or after run blocks                                | delay 5.seconds                                                                                                                                                                                                       |
| otherwise        | Block passed event                                                      | Multiple      |                                       |         | Code to execute on rule trigger if guards are not satisfied                 |                                                                                                                                                                                                                       |
| between          | Range of TimeOfDay or String Objects                                    | Single        |                                       |         | Only execute rule if current time is between supplied time ranges           | '6:05'..'14:05:05' (Include end) or '6:05'...'14:05:05' (Excludes end second) or TimeOfDay.new(h:6,m:5)..TimeOfDay.new(h:14,m:15,s:5)                                                                                 |
| only_if          | Item or Item Array, or Block                                            | Multiple      |                                       |         | Only execute rule if all supplied items are "On" and/or block returns true  | BedroomLightSwitch, BackyardLightSwitch or {BedroomLightSwitch.state == ON}                                                                                                                                           |
| not_if           | Item or Item Array, or Block                                            | Multiple      |                                       |         | Do **NOT** execute rule if any of the supplied items or blocks returns true | BedroomLightSwitch                                                                                                                                                                                                    |
| enabled          | Boolean                                                                 | Single        |                                       | true    | Enable or disable the rule from executing                                   |                                                                                                                                                                                                                       |

Last means that last value for the property is used <br>
Multiple indicates that multiple entries of the same property can be used in aggregate 


#### Property Values

##### Every

| Value             | Description                              | Example    |
| ----------------- | ---------------------------------------- | ---------- |
| :second           | Execute rule every second                | :second    |
| :minute           | Execute rule very minute                 | :minute    |
| :hour             | Execute rule every hour                  | :hour      |
| :day              | Execute rule every day                   | :day       |
| :week             | Execute rule every week                  | :week      |
| :month            | Execute rule every month                 | :month     |
| :year             | Execute rule one a year                  | :year      |
| :monday           | Execute rule every Monday at midnight    | :monday    |
| :tuesday          | Execute rule every Tuesday at midnight   | :tuesday   |
| :wednesday        | Execute rule every Wednesday at midnight | :wednesday |
| :thursday         | Execute rule every Thursday at midnight  | :thursday  |
| :friday           | Execute rule every Friday at midnight    | :friday    |
| :saturday         | Execute rule every Saturday at midnight  | :saturday  |
| :sunday           | Execute rule every Sunday at midnight    | :sunday    |
| [Integer].seconds | Execute a rule every X seconds           | 5.seconds  |
| [Integer].minutes | Execute rule every X minutes             | 3.minutes  |
| [Integer].hours   | Execute rule every X minutes             | 10.hours   |

| Option | Description                                                                                          | Example                                        |
| ------ | ---------------------------------------------------------------------------------------------------- | ---------------------------------------------- |
| :at    | Limit the execution to specific times of day. The value can either be a String or a TimeOfDay object | at: '16:45' or at: TimeOfDay.new(h: 16, m: 45) |


##### Examples

```ruby
rule 'Log the rule name every minute' do
  every :minute
  run { logger.info "Rule '#{name}' executed" }
end
```


```ruby
rule 'Log an entry at 11:21' do
  every :day, at: '11:21'
  run { logger.info("Rule #{name} run at #{TimeOfDay.now}") }
end

# The above rule could also be expressed using TimeOfDay class as below

rule 'Log an entry at 11:21' do
  every :day, at: TimeOfDay.new(h: 11, m: 21)
  run { logger.info("Rule #{name} run at #{TimeOfDay.now}") }
end
```


```ruby
rule 'Log an entry Wednesdays at 11:21' do
  every :wednesday, at: '11:21'
  run { logger.info("Rule #{name} run at #{TimeOfDay.now}") }
end
```


```ruby
rule 'Every 5 seconds' do
  every 5.seconds
  run { logger.info "Rule #{name} executed" }
end
```


##### Cron
Utilizes [OpenHAB style cron expressions](https://www.openhab.org/docs/configuration/rules-dsl.html#time-based-triggers) to trigger rules.  This property can be utilized when you need to represent complex expressions not possible with the simpler [every](#Every) syntax.

```ruby
rule 'Using Cron Syntax' do
  cron '43 46 13 ? * ?'
  run { logger.info "Cron rule executed" }
end
```



##### Changed
| Options | Description                                            | Example         |
| ------- | ------------------------------------------------------ | --------------- |
| from    | Only execute rule if previous state matches from state | from: OFF       |
| to      | Only execute rule if new state matches from state      | to: ON          |
| for     | Only execute rule if value stays changed for duration  | for: 10.seconds |

Changed accepts Items, Things or Groups. 

The from and to values operate exactly as they do in the DSL and Python rules with the exception of operating on Things.  If changed element being used as a trigger is a thing than the to and from values will accept symbols and strings, where the symbol matches the [supported status](https://www.openhab.org/docs/concepts/things.html). 

The for parameter provides a method of only executing the rule if the value is changed for a specific duration.  This provides a built-in method of only executing a rule if a condition is true for a period of time without the need to create dummy objects with the expire binding or make or manage your own timers.

For example, the code in [this design pattern](https://community.openhab.org/t/design-pattern-expire-binding-based-timers/32634) becomes (with no need to create the dummy object):
```ruby
rule "Execute rule when item is changed for specified duration" do
  changed Alarm_Mode, for: 20.seconds
  run { logger.info("Alarm Mode Updated")}
end
```

You can optionally provide from and to states to restrict the cases in which the rule executes:
```ruby
rule 'Execute rule when item is changed to specific number, from specific number, for specified duration' do
  changed Alarm_Mode, from: 8, to: 14, for: 12.seconds
  run { logger.info("Alarm Mode Updated")}
end
```

Works with things as well:
```ruby
rule 'Execute rule when thing is changed' do
   changed things['astro:sun:home'], :from => :online, :to => :uninitialized
   run { |event| logger.info("Thing #{event.uid} status <trigger> to #{event.status}") }
end
```


Real world example:
```ruby
rule 'Log (or notify) when an exterior door is left open for more than 5 minutes' do
  changed ExteriorDoors, to: OPEN, for: 5.minutes
  triggered {|door| logger.info("#{door.id} has been left open!")}
end
```


##### Updated
| Options | Description                                        | Example                 |
| ------- | -------------------------------------------------- | ----------------------- |
| to      | Only execute rule if update state matches to state | `to: 7` or `to: [7,14]` |

Changed accepts Items, Things or Groups. 

The to value restricts the rule from running to only if the updated state matches. If the updated element being used as a trigger is a thing than the to and from values will accept symbols and strings, where the symbol matches the [supported status](https://www.openhab.org/docs/concepts/things.html). 

The examples below assume the following background:

| type   | name             | group      | state |
| ------ | ---------------- | ---------- | ----- |
| Number | Alarm_Mode       | AlarmModes | 7     |
| Number | Alarm_Mode_Other | AlarmModes | 7     |


```ruby
rule 'Execute rule when item is updated to any value' do
  updated Alarm_Mode
  run { logger.info("Alarm Mode Updated") }
end
```

```ruby
rule 'Execute rule when item is updated to specific number' do
  updated Alarm_Mode, to: 7
  run { logger.info("Alarm Mode Updated") }
end
```

```ruby
rule 'Execute rule when item is updated to one of many specific states' do
  updated Alarm_Mode, to: [7,14]
  run { logger.info("Alarm Mode Updated")}
end
```

```ruby
rule 'Execute rule when group is updated to any state' do
  updated AlarmModes
  triggered { |item| logger.info("Group #{item.id} updated")}
end  
```

```ruby
rule 'Execute rule when member of group is changed to any state' do
  updated AlarmModes.items
  triggered { |item| logger.info("Group item #{item.id} updated")}
end 
```

```ruby
rule 'Execute rule when member of group is changed to one of many states' do
  updated AlarmModes.items, to: [7,14]
  triggered { |item| logger.info("Group item #{item.id} updated")}
end
```

Works with things as well:
```ruby
rule 'Execute rule when thing is updated' do
   updated things['astro:sun:home'], :to => :uninitialized
   run { |event| logger.info("Thing #{event.uid} status <trigger> to #{event.status}") }
end
```

##### Received_Command

| Options  | Description                                                          | Example                            |
| -------- | -------------------------------------------------------------------- | ---------------------------------- |
| command  | Only execute rule if the command matches this/these command/commands | `command: 7` or `commands: [7,14]` |
| commands | Alias of command, may be used if matching more than one command      | `commands: [7,14]`                 |

The `command` value restricts the rule from running to only if the command matches

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
  received_command Alarm_Mode, only: 7
  run { |event| logger.info("Item received command: #{event.command}" ) }
end
```

```ruby
rule 'Execute rule when item receives one of many specific commands' do
  received_command Alarm_Mode, only: [7,14]
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
  received_command AlarmModes.items
  triggered { |item| logger.info("Group item #{item.id} received command")}
end
```

```ruby
rule 'Execute rule when member of group is changed to one of many states' do
  received_command AlarmModes.items, only: [7,14]
  triggered { |item| logger.info("Group item #{item.id} received command")}
end
```


##### channel
| Option    | Description                                                                   | Example                                                |
| --------- | ----------------------------------------------------------------------------- | ------------------------------------------------------ |
| triggered | Only execute rule if the event on the channel matches this/these event/events | `triggered: 'START' ` or `triggered: ['START','STOP']` |
| thing     | Thing for specified channels                                                  | `thing: 'astro:sun:home'`                              |

The channel trigger executes rule when a specific channel is triggered.  The syntax supports one or more channels with one or more triggers.   For `thing` is an optional parameter that makes it easier to set triggers on multiple channels on the same thing.


```ruby
rule 'Execute rule when channel is triggered' do
  channel 'astro:sun:home:rise#event'      
  run { logger.info("Channel triggered") }
end

# The above is the same as the below

rule 'Execute rule when channel is triggered' do
  channel 'rise#event', thing: 'astro:sun:home'   
  run { logger.info("Channel triggered") }
end

```

```ruby
rule 'Rule provides access to channel trigger events in run block' do
  channel 'astro:sun:home:rise#event', triggered: 'START'
  run { |trigger| logger.info("Channel(#{trigger.channel}) triggered event: #{trigger.event}") }
end
```

```ruby
rule 'Rules support multiple channels' do
  channel ['rise#event','set#event'], thing: 'astro:sun:home' 
  run { logger.info("Channel triggered") }
end
```

```ruby
rule 'Rules support multiple channels and triggers' do
  channel ['rise#event','set#event'], thing: 'astro:sun:home', triggered: ['START', 'STOP'] 
  run { logger.info("Channel triggered") }
end
```

### Execution Blocks

#### Run
The run property is the automation code that is executed when a rule is triggered.  This property accepts a block of code and executes it. The block is automatically passed an event object which can be used to access multiple properties about the triggering event.  The code for the automation can be entirely within the run block can call methods defined in the ruby script.

##### State/Update Event Properties
The following properties exist when a run block is triggered from an [updated](#updated) or [changed](#changed) trigger. 

| Property | Description                      |
| -------- | -------------------------------- |
| item     | Triggering item                  |
| state    | Changed state of triggering item |
| last     | Last state of triggering item    |

##### Command Event Properties
The following properties exist when a run block is triggered from a [received_command](#received_command) trigger.

| Property | Description          |
| -------- | -------------------- |
| command  | Command sent to item |

##### Thing Event Properties
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
  run { |event| logger.info("#{event.item} triggered from #{event.last} to #{event.state}") }
end
```

`do/end` style used for multi-line blocks
```ruby
rule 'Multi Line Run Block' do
  changed TestSwitch
  run do |event|
    logger.info("#{event.item} triggered")
    logger.info("from #{event.last}") if event.last
    logger.info("to #{event.state}") if event.state
   end
end
```

Rules can have multiple run blocks and they are executed in order, Useful when used in combination with delay
```ruby
rule 'Multiple Run Blocks' do
  changed TestSwitch
  run { |event| logger.info("#{event.item} triggered") }
  run { |event| logger.info("from #{event.last}") if event.last }
  run { |event| logger.info("to #{event.state}") if event.state  }
end

```


#### Triggered
This property is the same as the run property except rather than passing an event object to the automation block the triggered item is passed. This enables optimizations for simple cases and supports ruby's [pretzel colon `&:` operator.](https://medium.com/@dcjones/the-pretzel-colon-75df46dde0c7) 

##### Examples
```ruby
rule 'Triggered has access directly to item triggered' do
  changed TestSwitch
  triggered { |item| logger.info("#{item.id} triggered") }
end

```

Triggered items are highly useful when working with groups
```ruby
#Switches is a group of Switch items

rule 'Triggered item is item changed when a group item is changed.' do
  changed Switches.items
  triggered { |item| logger.info("Switch #{item.id} changed to #{item}")}
end


rule 'Turn off any switch that changes' do
  changed Switches.items
  triggered(&:off)
end

```

Like other execution blocks, multiple triggered blocks are supported in a single rule
```ruby
rule 'Turn a switch off and log it, 5 seconds after turning it on' do
  changed Switches.items, to: ON
  delay 5.seconds
  triggered(&:off)
  triggered {|item| logger.info("#{item.label} turned off") }
end
```


#### Delay
The delay property is a non thread-blocking element that is executed after, before, or between run blocks. 

```ruby
rule 'Delay sleeps between execution elements' do
  on_start
  run { logger.info("Sleeping") }
  delay 5.seconds
  run { logger.info("Awake") }
end
```

Like other execution blocks, multiple can exist in a single rule.

```ruby
rule 'Multiple delays can exist in a rule' do
  on_start
  run { logger.info("Sleeping") }
  delay 5.seconds
  run { logger.info("Sleeping Again") }
  delay 5.seconds
  run { logger.info("Awake") }
end
```


You can use ruby code in your rule across multiple execution blocks like a run and a delay. 
```ruby
rule 'Dim a switch on system startup over 100 seconds' do
   on_start
   100.times do
     run { DimmerSwitch.dim }
     delay 1.second
   end
 end

```


#### Otherwise
The otherwise property is the automation code that is executed when a rule is triggered and guards are not satisfied.  This property accepts a block of code and executes it. The block is automatically passed an event object which can be used to access multiple properties about the triggering event. 

##### Event Properties
| Property | Description                      |
| -------- | -------------------------------- |
| item     | Triggering item                  |
| state    | Changed state of triggering item |
| last     | Last state of triggering item    |

```ruby
rule 'Turn switch ON or OFF based on value of another switch' do
  on_start
  run { TestSwitch << ON }
  otherwise { TestSwitch << OFF }
  only_if { OtherSwitch == ON }
end
```



### Guards

Guards exist to only permit rules to run if certain conditions are satisfied. Think of these as declarative if statements that keep the run block free of conditional logic, although you can of course still use conditional logic in run blocks if you prefer. 

only_if and not_if guards that are provided objects rather than blocks automatically check for the 'truthyness' of the supplied object.  

Truthyness for Item types:

| Item    | Truthy when |
| ------- | ----------- |
| Switch  | state == ON |
| Dimmer  | state != 0  |
| Contact | Not Defined |
| String  | Not Blank   |
| Number  | state != 0  |


#### only_if
 only_if allows rule execution when result is true and prevents when false.
 
```ruby
rule 'Set OutsideDimmer to 50% if LightSwtich turned on and OtherSwitch is also ON' do
  changed LightSwitch, to: ON
  run { OutsideDimmer << 50 }
  only_if { OtherSwitch == ON }
end
```

Because only_if uses 'truthy?' on non-block objects the above rule can also be written like this:

```ruby
rule 'Set OutsideDimmer to 50% if LightSwtich turned on and OtherSwitch is also ON' do
  changed LightSwitch, to: ON
  run { OutsideDimmer << 50 }
  only_if OtherSwitch
end
```

multiple only_if statements can be used and **all** must be true for the rule to run.

```ruby
rule 'Set OutsideDimmer to 50% if LightSwtich turned on and OtherSwitch is also ON and Door is closed' do
  changed LightSwitch, to: ON
  run { OutsideDimmer << 50 }
  only_if OtherSwitch
  only_if { Door == CLOSED }
end
```


#### not_if

not_if allows prevents execution of rules when result is false and prevents when true

```
 rule 'Set OutsideDimmer to 50% if LightSwtich turned on and OtherSwitch is OFF' do
        changed LightSwitch, to: ON
        run { OutsideDimmer << 50 }
        not_if { OtherSwitch == ON }
      end
```

Because not_if uses 'truthy?' on non-block objects the above rule can also be written like this:

```ruby
rule 'Set OutsideDimmer to 50% if LightSwtich turned on and OtherSwitch is OFF' do
  changed LightSwitch, to: ON
  run { OutsideDimmer << 50 }
  not_if OtherSwitch
end
```

Multiple not_if statements can be used and if **any** of them are not satisfied the rule will not run. 

```ruby
rule 'Set OutsideDimmer to 50% if LightSwtich turned on and OtherSwitch is OFF and Door is not CLOSED' do
  changed LightSwitch, to: ON
  run { OutsideDimmer << 50 }
  not_if OtherSwitch
  not_if { Door == CLOSED }
end
```

#### Guard Combination

only_if and not_if can be used on the same rule, both be satisfied for a rule to execute.

```ruby
rule 'Set OutsideDimmer to 50% if LightSwtich turned on and OtherSwitch is OFF and Door is CLOSED' do
  changed LightSwitch, to: ON
  run { OutsideDimmer << 50 }
  only_if { Door == CLOSED }
  not_if OtherSwitch
end
```


#### Guard Event Access
Guards have access to event information.

```ruby
rule 'Set OutsideDimmer to 50% if any switch in group Switches starting with Outside is switched On' do
  changed Switches.items, to: ON
  run { OutsideDimmer << 50 }
  only_if { |event| event.item.name.start_with? 'Outside' }
end
```


#### between
Only runs the rule if the current time is in the provided range

```ruby
rule 'Log an entry if started between 3:30:04 and midnight using strings' do
  on_start
  run { logger.info ("Started at #{TimeOfDay.now}")}
  between '3:30:04'..MIDNIGHT
end
```

or

```ruby
rule 'Log an entry if started between 3:30:04 and midnight using TimeOfDay objects' do
  on_start
  run { logger.info ("Started at #{TimeOfDay.now}")}
  between TimeOfDay.new(h: 3, m: 30, s: 4)..TimeOfDay.midnight
end
```


### Items
Items can be directly accessed, compared, etc, without any special accessors. You may use the item name anywhere within the code and it will automatically be loaded.

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

```ruby
logger.info("Item Count: #{items.count}")  # Item Count: 2
logger.info("Items: #{items.sort_by(&:label).map(&:label).join(', ')}")  #Items: Test Dimmer, Test Switch' 
```

```ruby
rule 'Use dynamic item lookup to increase related dimmer brightness when switch is turned on' do
  changed SwitchTest, to: ON
  triggered { |item| items[item.name.gsub('Switch','Dimmer')].brighten(10) }
end
```

#### All Items
Item types have methods added to them to make it flow naturally within the a ruby context.  All methods of the OpenHAB item are available plus the additional methods described below.


| Method  | Description                                       | Example                                                      |
| ------- | ------------------------------------------------- | ------------------------------------------------------------ |
| <<      | Sends command to item                             | `VirtualSwich << ON`                                         |
| command | alias for shovel operator (<<)                    | `VirtualSwich.command(ON)`                                   |
| update  | Sends update to an item                           | `VirtualSwitch.update(ON)`                                   |
| id      | Returns label or item name if no label            | `logger.info(#{item.id})`                                    |
| undef?  | Returns true if the state of the item is UNDEF    | `logger.info("SwitchTest is UNDEF") if SwitchTest.undef?`    |
| null?   | Returns true if the state of the item is NULL     | `logger.info("SwitchTest is NULL") if SwitchTest.null?`      |
| state?  | Returns true if the state is not UNDEF or NULL    | `logger.info("SwitchTest has a state") if SwitchTest.state?` |
| state   | Returns state of the item or nil if UNDEF or NULL | `logger.info("SwitchTest state #{SwitchTest.state}")`        |
| to_s    | Returns state in string format                    | `logger.info(#{item.id}: #{item})`                           |

State returns nil instead of UNDEF or NULL so that it can be used with with [Ruby safe navigation operator](https://ruby-doc.org/core-2.6/doc/syntax/calling_methods_rdoc.html) `&.`  Use `undef?` or `null?` to check for those states.

To operate across an arbitrary collection of items you can place them in an [array](https://ruby-doc.org/core-2.5.0/Array.html) and execute methods against the array.

```ruby
number_items = [Livingroom_Temp, Bedroom_Temp]
logger.info("Max is #{number_items.max}")
logger.info("Min is #{number_items.min}")
```


#### Switch Item
This class is aliased to **Switch** so you can compare compare item types using ` item.is_a? Switch or grep(Switch)`

| Method  | Description                               | Example                                         |
| ------- | ----------------------------------------- | ----------------------------------------------- |
| truthy? | Item is not undefined, not null and is ON | `puts "#{item.name} is truthy" if item.truthy?` |
| on      | Send command to turn item ON              | `item.on`                                       |
| off     | Send command to turn item OFF             | `item.off`                                      |
| on?     | Returns true if item state == ON          | `puts "#{item.name} is on." if item.on?`        |
| off?    | Returns true if item state == OFF         | `puts "#{item.name} is off." if item.off?`      |
| !       | Return the inverted state of the item     | `item << !item`                                 |


Switches respond to `on` and `off`

```ruby
# Turn on all switches in a group called Switches
Switches.each(&:on)
```

Check state with `off?` and `on?`

```ruby
# Turn on all switches in a group called Switches that are off
Switches.select(&:off?).each(&:on)
```

Switches can be selected in an enumerable with grep.

```ruby
items.grep(Switch)
     .each { |switch| logger.info("Switch #{switch.id} found") }
```

Switch states also work in grep.
```ruby
# Log all switch items set to ON
items.grep(Switch)
     .grep(ON)
     .each { |switch| logger.info("#{switch.id} ON") }

# Log all switch items set to OFF
items.grep(Switch)
     .grep(OFF)
     .each { |switch| logger.info("#{switch.id} OFF") }
```

Switch states also work in case statements.
```ruby
items.grep(Switch)
     .each do |switch|
        case switch
        when ON
          logger.info("#{switch.id} ON")
        when OFF
          logger.info("#{switch.id} OFF")
         end
      end
```


Other examples
```ruby
# Invert all switches
items.grep(Switch)
     .each { |item| if item.off? then item.on else item.off end}

# Or using not operator

items.grep(Switch)
     .each { |item| item << !item } 

```



#### DimmerItem
This class is aliased to **Dimmer** so you can compare compare item types using ` item.is_a? Dimmer or grep(Dimmer)`

| Method   | Parameters         | Description                                  | Example                                         |
| -------- | ------------------ | -------------------------------------------- | ----------------------------------------------- |
| truthy?  |                    | Item state not UNDEF, not NULL and is ON     | `puts "#{item.name} is truthy" if item.truthy?` |
| on       |                    | Send command to turn item ON                 | `item.on`                                       |
| off      |                    | Send command to turn item OFF                | `item.off`                                      |
| on?      |                    | Returns true if item state == ON             | `puts "#{item.name} is on." if item.on?`        |
| off?     |                    | Returns true if item state == OFF            | `puts "#{item.name} is off." if item.off?`      |
| dim      | amount (default 1) | Dim the switch the specified amount          | `DimmerSwitch.dim`                              |
| -        | amount             | Subtract the supplied amount from DimmerItem | `DimmerSwitch << DimmerSwitch - 5`              |
| brighten | amount (default 1) | Brighten the switch the specified amount     | `DimmerSwitch.brighten`                         |
| +        | amount             | Add the supplied amount from the DimmerItem  | `DimmerSwitch << DimmerSwitch + 5`              |


##### Examples

```ruby
DimmerOne << DimmerOne - 5
DimmerOne << 100 - DimmerOne

```

`on`/`off` sends commands to a Dimmer

```ruby
# Turn on all dimmers in group
Dimmers.each(&:on)

# Turn off all dimmers in group
Dimmers.each(&:off)
```

 `on?`/`off?` Checks state of dimmer

```ruby
# Turn on switches that are off
Dimmers.select(&:off?).each(&:on)
	  
# Turn off switches that are on
Dimmers.select(&:on?).each(&:off)
```

`dim` dims the specified amount, defaulting to 1. If 1 is the amount, the decrease command is sent, otherwise the current state - amount is sent as a command.

```ruby
DimmerOne.dim
DimmerOne.dim 2
```

`brighten` brightens the specified amount, defaulting to 1. If 1 is the amount, the increase command is sent, otherwise the current state + amount is sent as a command.

```ruby
DimmerOne.brighten
DimmerOne.brighten 2   
```

Dimmers can be selected in an enumerable with grep.

```ruby
# Get all dimmers
items.grep(Dimmer)
     .each { |dimmer| logger.info("#{dimmer.id} is a Dimmer") }
```

Dimmers work with ranges and can be used in grep.

```ruby
# Get dimmers with a state of less than 50
items.grep(Dimmer)
     .grep(0...50)
     .each { |item| logger.info("#{item.id} is less than 50") }
```

Dimmers can also be used in case statements with ranges.
```ruby
#Log dimmer states partioning aat 50%
items.grep(Dimmer)
     .each do |dimmer|
       case dimmer
       when (0..50)
         logger.info("#{dimmer.id} is less than 50%")
        when (51..100)
         logger.info("#{dimmer.id} is greater than 50%")
         end
end
```

Other examples

```ruby
rule 'Dim a switch on system startup over 100 seconds' do
  on_start
  100.times do
    run { DimmerSwitch.dim }
    delay 1.second
  end
end

```

```ruby
rule 'Dim a switch on system startup by 5, pausing every second' do
   on_start
   100.step(-5, 0) do | level |
     run { DimmerSwitch << level }
     delay 1.second
   end
end
```

```ruby
rule 'Turn off any dimmers curently on at midnight' do
   every :day
   run do
     items.grep(Dimmer)
          .select(&:on?)
          .each(&:off)
    end
end
```

```ruby
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

This class is aliased to **Contact** so you can compare compare item types using ` item.is_a? Contact or grep(Contact)`


| Method  | Description                          | Example                                   |
| ------- | ------------------------------------ | ----------------------------------------- |
| open?   | Returns true if item state == OPEN   | `puts "#{item} is closed." if item.open?` |
| closed? | Returns true if item state == CLOSED | `puts "#{item} is off." if item.closed`   |


##### Examples

`open?`/`closed?` checks state of contact

```ruby
# Log open contacts
Contacts.select(&:open?).each { |contact| logger.info("Contact #{contact.id} is open")}

# Log closed contacts
Contacts.select(&:closed?).each { |contact| logger.info("Contact #{contact.id} is closed")}

```

Contacts can be selected in an enumerable with grep.

```ruby
# Get all Contacts
items.grep(Contact)
     .each { |contact| logger.info("#{contact.id} is a Contact") }
```

Contacts states work in grep.

```ruby
# Log all open contacts in a group
Contacts.grep(OPEN)
        .each { |contact| logger.info("#{contact.id} is in #{contact}") }

# Log all closed contacts in a group
Contacts.grep(CLOSED)
        .each { |contact| logger.info("#{contact.id} is in #{contact}") }

```

Contact states work in case statements.

```ruby
#Log if contact is open or closed
case TestContact
when (OPEN)
  logger.info("#{TestContact.id} is open")
when (CLOSED)
  logger.info("#{TestContact.id} is closed")
end
```


Other examples

```ruby
rule 'Log state of all doors on system startup' do
  on_start
  run do
    Doors.each do |door|
      case door
      when OPEN then logger.info("#{door.id} is Open")
      when CLOSED then logger.info("#{door.id} is Open")
      else logger.info("#{door.id} is not initialized")
      end
    end
  end
end

```

#### Number Item

| Method          | Parameters | Description                                                                                                                                              | Example                                                                      |
| --------------- | ---------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------- |
| truthy?         |            | Item state not UNDEF, not NULL and is not Zero                                                                                                           | `puts "#{item.name} is truthy" if item.truthy?`                              |
| +,-,\*,/        | amount     | Perform the operation between the state of the number item and the supplied value*                                                                       | `NumberItem << NumberItem - 5` or `NumberItem << 10 + NumberItem`            |
| \|              | unit       | Convert the supplied NumberItem to the supplied unit. Unit can either be a Unit class or string representation of the symbol, returns a Quantity object. | `NumberItem` &#124; `ImperialUnits::FAHRENHEIT` or `NumberItem `&#124;`'°F'` |
| to_d            |            | Returns the state as a BigDecimal or nil if state is UNEF or NULL                                                                                        | `NumberOne.to_d`                                                             |
| to_i            |            | Returns the state as an Integer or nil if state is UNEF or NULL                                                                                          | `NumberOne.to_i`                                                             |
| to_f            |            | Returns the state as a Float or nil if state is UNEF or NULL                                                                                             | `NumberOne.to_f`                                                             |
| dimension       |            | Returns the dimension of the Number Item, nil if the number is dimensionless                                                                             | `Numberone.dimension`                                                        |
| Numeric Methods |            | All methods for [Ruby Numeric](https://ruby-doc.org/core-2.5.0/Numeric.html)                                                                             |                                                                              |

 Math operations for dimensionless numbers return a type of [Ruby BigDecimal](https://ruby-doc.org/stjjdlib-2.5.1/libdoc/bigdecimal/rdoc/BigDecimal.html).  Check [Quantities section](#Quantities) for details of how math operations impact dimensioned numbers. 


##### Examples

Math operations can be performed directly on the NumberItem

```ruby
# Add 5 to a number item
NumberOne << NumberOne + 5

# Add Number item to 5
NumberOne << 5 + NumberOne

```

Number Items can be selected in an enumerable with grep.

```ruby
# Get all NumberItems
items.grep(NumberItem)
      .each { |number| logger.info("#{number.id} is a Number Item") }
```

Number Item work with ranges and can be used in grep.

```ruby
# Get numbers in group Numbers with a state of less than 50
      # Get all NumberItems less than 50
      Numbers.grep(0...50)
           .each { |number| logger.info("#{number.id} is less than 50") }
```

Number Items can also be used in case statements with ranges.
```ruby
#Check if number items is less than 50
case NumberOne
when (0...50)
  logger.info("#{NumberOne.id} is less than 50")
when (50..100)
  logger.info("#{NumberOne.id} is greater than 50")
end
```


#### Quantities 
Quantities are part of the [Units of Measurement](https://www.openhab.org/docs/concepts/units-of-measurement.html) framework in OpenHAB.  The quantity object acts as ruby wrapper around the OpenHAB QuantityType.

| Method             | Parameters | Description                                                                                                                | Example                                                                      |
| ------------------ | ---------- | -------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------- |
| +,-,\*,/,-(negate) | amount     | Perform the operation between the state of the number item and the supplied value*                                         | `NumberItem << NumberItem - 5` or `NumberItem << 10 + NumberItem`            |
| \|                 | unit       | Convert the supplied Quantity to the supplied unit. Unit can either be a Unit class or string representation of the symbol | `NumberItem` &#124; `ImperialUnits::FAHRENHEIT` or `NumberItem `&#124;`'°F'` |
| quantity           |            | Returns the underlying OpenHAB QuantityType object                                                                         | `Numberone.dimension`                                                        |
| Numeric Methods    |            | All methods for [Ruby Numeric](https://ruby-doc.org/core-2.5.0/Numeric.html)                                               |                                                                              |

###### Examples

Quantity types can perform math operations between them.  

```ruby
Quantity.new('50 °F') + -Quantity.new('25 °F') = 25.0 °F
Quantity.new('100 °F') / Quantity.new('2 °F') = 50
Quantity.new('50 °F') * Quantity.new('2 °F') = 100 °F
Quantity.new('50 °F') - Quantity.new('25 °F') = 25 °F
Quantity.new('50 °F') + Quantity.new('50 °F') = 100 °F
```

If the operand is a string it will be automatically converted into a Quantity. 
```ruby
Quantity.new('100 °F') / '2 °F' = 50
Quantity.new('50 °F') * '2 °F' = 100 °F
Quantity.new('50 °F') - '25 °F' = 25 °F
Quantity.new('50 °F') + '50 °F' = 100 °F
```

If the operand is a number, it will be unit-less, but the result of the operation will have a unit.  This only works for multiplication and division. 
```ruby
Quantity.new('50 °F')  * 2 = 100 °F
Quantity.new('100 °F') / 2 = 50 °F 
```

If the operand is a dimensioned NumberItem it will automatically be converted to a quantity for the operation.
```ruby
# NumberF = '2 °F'
# NumberC = '2 °C'

Quantity.new('50 °F') + NumberF # = 52.0 °F
Quantity.new('50 °F') + NumberC # = 85.60 °F 
```

If the operand is a non-dimensioned NumberItem it can be used only in multiplication and division operations.

```ruby
# Number Dimensionless = 2

Quantity.new('50 °F') * Dimensionless # = 100 °F   
Quantity.new('50 °F') / Dimensionless # = 25 °F    
```

Quantities can be compared, if they have comparable units.
```ruby
Quantity.new('50 °F') >  Quantity.new('25 °F')  
Quantity.new('50 °F') >  Quantity.new('525 °F') 
Quantity.new('50 °F') >= Quantity.new('50 °F')  
Quantity.new('50 °F') == Quantity.new('50 °F')  
Quantity.new('50 °F') <  Quantity.new('25 °C')  
```

If the compare-to is a string, it will be automatically converted into a quantity.
```ruby
Quantity.new('50 °F') == '50 °F' 
Quantity.new('50 °F') <  '25 °C'
```

Dimensioned Number Items can be converted to quantities with other units using the \| operator

```ruby
# NumberC = '23 °C'

# Using a unit 
logger.info("In Fahrenheit #{NumberC| ImperialUnits::FAHRENHEIT }")

# Using a string
logger.info("In Fahrenheit #{NumberC | '°F'}")

```

Dimensionless Number Items can be converted to quantities with units using the \| operator

```ruby
# Dimensionless = 70

# Using a unit 
logger.info("In Fahrenheit #{Dimensionless| ImperialUnits::FAHRENHEIT }")

# Using a string
logger.info("In Fahrenheit #{Dimensionless | '°F'}")

```

Dimensioned Number Items automatically use their units and convert automatically for math operations

```ruby
# Number:Temperature NumberC = 23 °C
# Number:Temperature NumberF = 70 °F

NumberC - NumberF # = 1.88 °C
NumberF + NumberC # = 143.40 °F 
```

Dimensionless Number Items can be used for multiplication and division. 

```ruby
# Number Dimensionless = 2
# Number:Temperature NumberF = 70 °F

NumberF * Dimensionless # = 140.0 °F 
NumberF / Dimensionless # = 35.0 °F
Dimensionless * NumberF # = 140.0 °F 
2 * NumberF             # = 140.0 °F 
```

Comparisons work on dimensioned number items with different, but comparable units.
```ruby
# Number:Temperature NumberC = 23 °C
# Number:Temperature NumberF = 70 °F

NumberC > NumberF # = true
```

Comparisons work with dimensioned numbers and strings representing quantities
```ruby
# Number:Temperature NumberC = 23 °C
# Number:Temperature NumberF = 70 °F

NumberC > '4 °F'   #= true 
NumberC == '23 °C' #= true  
```

For certain unit types, such as temperature, all unit needs to be normalized to the comparator for all operations when combining comparison operators with dimensioned numbers.

```ruby
(NumberC |'°F') - (NumberF |'°F') < '4 °F' 
```

To facilitate conversion of multiple dimensioned and dimensionless numbers the unit block may be used.  The unit block attempts to do the _right thing_ based on the mix of dimensioned and dimensionless items within the block.  Specifically all dimensionless items are converted to the supplied unit, except when they are used for multiplication or division. 

```ruby
# Number:Temperature NumberC = 23 °C
# Number:Temperature NumberF = 70 °F
# Number Dimensionless = 2

unit('°F') { NumberC - NumberF < 4 }               					#= true   
unit('°F') { NumberC - '24 °C' < 4 }               					#= true   
unit('°F') { Quantity.new('24 °C') - NumberC < 4 }					#= true   
unit('°C') { NumberF - '20 °C' < 2 }               					#= true   
unit('°C') { NumberF - Dimensionless }             					#= 19.11 °C
unit('°C') { NumberF - Dimensionless < 20 }        					#= true   
unit('°C') { Dimensionless + NumberC == 25 }       					#= true     unit('°C') { 2 + NumberC == 25 }                   					#= true
unit('°C') { Dimensionless * NumberC == 46 }       					#= true      unit('°C') { 2 * NumberC == 46 }                   				 #= true
unit('°C') { ( (2 * (NumberF + NumberC) ) / Dimensionless ) < 45} 	#= true      unit('°C') { [NumberC, NumberF, Dimensionless].min }              	 #= 2       
```

#### String Item

| Method          | Parameters | Description                                                                | Example                                          |
| --------------- | ---------- | -------------------------------------------------------------------------- | ------------------------------------------------ |
| truthy?         |            | Item state not UNDEF, not NULL and is not blank ('') when trimmed.         | `puts "#{item.name} is truthy" if item.truthy?`  |
| String methods* |            | All methods for [Ruby String](https://ruby-doc.org/core-2.5.1/String.html) | `StringOne << StringOne + ' World!'`             |
| blank?          |            | True if state is UNDEF, NULL, string is empty or contains only whitepspace | `StringOne << StringTwo unless StringTwo.blank?` |

* All String methods returns a copy of the current state as a string.  Methods that modify a string in place, do not modify the underlying state string. 
 
 
##### Examples

String operations can be performed directly on the StringItem

```ruby
# StringOne has a current state of "Hello"
StringOne << StringOne + " World!"
# StringOne will eventually have a state of 'Hello World!'

# Add Number item to 5
NumberOne << 5 + NumberOne

```

String Items can be selected in an enumerable with grep.

```ruby
# Get all StringItems
items.grep(StringItem)
     .each { |string| logger.info("#{string.id} is a String Item") }
```

String Item values can be matched against regular expressions

```ruby
# Get all Strings that start with an H
Strings.grep(/^H/)
        .each { |string| logger.info("#{string.id} starts with an H") }
```

### Groups

A group can be accessed directly by name, to access all groups use the `groups` method. 


#### Group Methods

| Method             | Description                                                                                     |
| ------------------ | ----------------------------------------------------------------------------------------------- |
| group              | Access Group Item                                                                               |
| items              | Used to inform a rule that you want it to operate on the items in the group (see example below) |
| groups             | Direct subgroups of this group                                                                  |
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

```ruby
#Operate on items in a group using enumerable methods
logger.info("Total Temperatures: #{Temperatures.count}")     #Total Temperatures: 3'
logger.info("Temperatures: #{House.sort_by(&:label).map(&:label).join(', ')}") #Temperatures: Bedroom temperature, Den temperature, Living Room temperature' 

#Access to the group object via the 'group' method
logger.info("Group: #{Temperatures.group.name}" # Group: Temperatures'

#Operates on items in nested groups using enumerable methods
logger.info("House Count: #{House.count}")           # House Count: 3
llogger.info("Items: #{House.sort_by(&:label).map(&:label).join(', ')}")  # Items: Bedroom temperature, Den temperature, Living Room temperature

#Access to sub groups using the 'groups' method
logger.info("House Sub Groups: #{House.groups.count}")  # House Sub Groups: 2
logger.info("Groups: #{House.groups.sort_by(&:id).map(&:id).join(', ')}")  # Groups: GroundFloor, Sensors

```


```ruby
rule 'Turn off any switch that changes' do
  changed Switches.items
  triggered &:off
end
```

Built in [enumerable](https://ruby-doc.org/core-2.5.1/Enumerable.html)/[set](https://ruby-doc.org/stdlib-2.5.1/libdoc/set/rdoc/Set.html) functions can be applied to groups.  
```ruby
logger.info("Max is #{Temperatures.max}")
logger.info("Min is #{Temperatures.min}")
```

### Things
Things can be access using the `things` method and subsequent operations on that methods. 

| Method             | Description                                                         |
| ------------------ | ------------------------------------------------------------------- |
| things             | Return all things as a Ruby Set                                     |
| []                 | Get a specific thing by name                                        |
| enumerable methods | All methods [here](https://ruby-doc.org/core-2.5.0/Enumerable.html) |

```ruby
things.each { |thing| logger.info("Thing: #{thing.uid}")}
```

```ruby
logger.info("Thing: #{things['astro:sun:home'].uid}")
```

For thing objects now additional methods are provided, however the standard [JRuby alternate names and bean convention applies](https://github.com/jruby/jruby/wiki/CallingJavaFromJRuby#alternative-names-and-beans-convention), such that `getUID` becomes `uid`.



### Logging
Logging is available everywhere through the logger object.  The name of the rule file is automatically appended to the logger name. Pending [merge](https://github.com/openhab/openhab-core/pull/1885) into the core.

```ruby
logger.trace('Test logging at trace') # 2020-12-03 18:05:20.903 [TRACE] [jsr223.jruby.log_test               ] - Test logging at trace
logger.debug('Test logging at debug') # 2020-12-03 18:05:32.020 [DEBUG] [jsr223.jruby.log_test               ] - Test logging at debug
logger.warn('Test logging at warn') # 2020-12-03 18:05:41.817 [WARN ] [jsr223.jruby.log_test               ] - Test logging at warn
logger.info('Test logging at info') # Test logging at info
logger.error('Test logging at error') # 2020-12-03 18:06:02.021 [ERROR] [jsr223.jruby.log_test               ] - Test logging at error
```

### Ruby Gems
[Bundler](https://bundler.io/) is integrated, enabling any [Ruby gem](https://rubygems.org/) compatible with JRuby to be used within rules. This permits easy access to the vast ecosystem libraries within the ruby community.  It would also create easy reuse of automation libraries within the OpenHAB community, any library published as a gem can be easily pulled into rules. 

Gems are available using the [inline bundler syntax](https://bundler.io/guides/bundler_in_a_single_file_ruby_script.html). The require statement can be omitted. 


```ruby
gemfile do
  source 'https://rubygems.org'
   gem 'json', require: false
   gem 'nap', '1.1.0', require: 'rest'
end

logger.info("The nap gem is at version #{REST::VERSION}")     
```

### Duration
[Ruby integers](https://ruby-doc.org/core-2.5.0/Integer.html) are extended with several methods to support durations.  These methods create a new duration object that is used by the [Every trigger](#Every), the [for option](#Changed) and [timers](#Timers). 

Extended Methods

| Method                            | Description                    |
| --------------------------------- | ------------------------------ |
| hour or hours                     | Convert number to hours        |
| minute or minutes                 | Convert number to minutes      |
| second or seconds                 | Convert number to seconds      |
| millisecond or milliseconds or ms | Convert number to milliseconds |


### Timers
Timers are created using the `after` method. 

After method parameters

| Parameter | Description                                                        |
| --------- | ------------------------------------------------------------------ |
| duration  | Duration for timer                                                 |
| block     | Block to execute after duration, block will be passed timer object |

Timer Object
The timer object has all of the methods of the [OpenHAB Timer](https://www.openhab.org/docs/configuration/actions.html#timers) with a change to the reschedule method to enable it to operate Ruby context. 


`reschedule` method parameters

| Parameter | Description                                                                                      |
| --------- | ------------------------------------------------------------------------------------------------ |
| duration  | Optional [duration](#Duration) if unspecified original duration supplied to after method is used |



```ruby
after 5.seconds do
  logger.info("Timer Fired")
end
```

```ruby
# Timers delegate methods to OpenHAB timer objects
after 1.second do |timer|
  logger.info("Timer is active? #{timer.is_active}")
end
```

```ruby
# Timers can be rescheduled to run again, waiting the original duration
after 3.seconds do |timer|
  logger.info("Timer Fired")
  timer.reschedule
end
```

```ruby
# Timers can be rescheduled for different durations
after 3.seconds do |timer|
  logger.info("Timer Fired")
  timer.reschedule 5.seconds
end
```


## Examples

### Log "Rule *name* executed" an entry every minute

```ruby
rule 'Simple' do
  every :minute
  run { logger.info "Rule #{name} executed" }
end

```


### The rule definition itself is just ruby code

Meaning you can use code itself to generate your rules*

```ruby
rule 'Log whenever a Virtual Switch Changes' do
  items.select { |item| item.is_a? Switch }
       .select { |item| item.label&.include? 'Virtual' }
       .each do |item|
         changed item
       end

  run { |event| logger.info "#{event.item.id} changed from #{event.last} to #{event.state}" }
end
```

Which is the same as
```ruby
virtual_switches = items.select { |item| item.is_a? Switch }
                        .select { |item| item.label&.include? 'Virtual' }

rule 'Log whenever a Virtual Switch Changes 2' do
  changed virtual_switches
  run { |event| logger.info "#{event.item.id} changed from #{event.last} to #{event.state} 2" }
end
```

This will accomplish the same thing, but create a new rule for each virtual switch*
```ruby
virtual_switches = items.select { |item| item.is_a? Switch }
                        .select { |item| item.label&.include? 'Virtual' }

virtual_switches.each do |switch|
  rule "Log whenever a #{switch.label} Changes" do
    changed switch
    run { |event| logger.info "#{event.item.id} changed from #{event.last} to #{event.state} 2" }
  end
end
```

* Take care when doing this as the the items/groups are processed when the rules file is processed, meaning that new items/groups will not automatically generate new rules. 



##### Conversion Examples

DSL

```ruby
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
```ruby
rule 'Snap Fan to preset percentages' do
  changed(*CeilingFans)
  triggered do |item|
    snapped = case item
              when 0...25 then 25
              when 26...66 then 66
              when 67...100 then 100
              end
    if snapped
       logger.info("Snapping fan #{item.id} to #{snapped}")
      item << snapped
    else
      logger.info("#{item.id} set to snapped percentage, no action taken.")
    end
  end
end
```

Python
```python
@rule("Use Supplemental Heat In Office")
@when("Item Office_Temperature changed")
@when("Item Thermostats_Upstairs_Temp changed")
@when("Item Office_Occupied changed")
@when("Item OfficeDoor changed")
def office_heater(event):
  office_temp = ir.getItem("Office_Temperature").getStateAs(QuantityType).toUnit(ImperialUnits.FAHRENHEIT).floatValue()
  hall_temp = items["Thermostats_Upstairs_Temp"].floatValue()
  therm_status = items["Thermostats_Upstairs_Status"].intValue()
  heat_set = items["Thermostats_Upstairs_Heat_Set"].intValue()
  occupied = items["Office_Occupied"]
  door = items["OfficeDoor"]
  difference = hall_temp - office_temp
  logging.warn("Office Temperature: {} Upstairs Hallway Temperature: {} Differnce: {}".format(office_temp,hall_temp,difference))
  logging.warn("Themostat Status: {} Heat Set: {}".format(therm_status,heat_set))
  logging.warn("Office Occupied: {}".format(occupied))
  logging.warn("Office Door: {}".format(door))
  degree_difference = 2.0
  trigger = False
  if heat_set > office_temp:
    if difference > degree_difference:
     if occupied == ON:
      if True:
          if therm_status == 0:
            if door == CLOSED:
                trigger = True
            else:
               logging.warn("Door Open, no action taken")
          else:
            logging.warn("HVAC on, no action taken")
      else:
        logging.warn("Office unoccupied, no action taken")
    else:
      logging.warn("Thermstat and office temperature difference {} is less than {} degrees, no action taken".format(difference, degree_difference))
  else:
    logging.warn("Heat set lower than office temp, no action taken".format(difference, degree_difference))


  if trigger:
    logging.warn("Turning on heater")
    events.sendCommand("Lights_Office_Outlet","ON")
  else:
    logging.warn("Turning off heater")
    events.sendCommand("Lights_Office_Outlet","OFF")
```


Ruby
```ruby
rule 'Use supplemental heat in office' do
  changed Office_Temperature, Thermostats_Upstairs_Temp, Office_Occupied, OfficeDoor
  run { Lights_Office_Outlet << ON }
  only_if Office_Occupied
  only_if { OfficeDoor == CLOSED }
  only_if { Thermostate_Upstairs_Heat_Set > Office_Temperature }
  only_if { unit(°F') { Thermostat_Upstairs_Temp - Office_Temperature > 2 } }
  otherwise { Lights_Office_Outlet << OFF if Lights_Office_Outlet.on? }
end
```


