# JRuby 

## Design points
- Create an intuitive method of defining rules and automation
- Abstract away complexities of Openhab (Timers, Item.state vs Item)
- Enable all the power of Ruby and OpenHab
-  Create a 'Frictionless' experience for building automation
-  Extensible 

## Why Ruby?
- It was designed for programmer productivity with the idea that programming should be fun for programmers.
- It emphasizes the necessity for software to be understood by humans first and computers second.
- For me automation is a hobby, I want to enjoy writing automation not fight compilers.
- Rich ecosystem, including Rubocop to help developers create good code.
-  Ruby is really good at letting you express yourself and creating a DSL within ruby (that is still ruby) to make expression easier.
-  Easily extensible


## Notes:
- All items, groups and things are automatically available, no need to "getItem", etc.
- channels are available as "dot notation" on things
- List of items are avilable as "items" and do not include groups
- List of groups are avilable as "groups"
-- While conceptionaly in openhab they are stored as items, their uses are quite different in most cases and you don't use them interchangably.

##  Syntax
```
rule 'name' do
   <one of many triggers>
   run do
      <automation code goes here>
   end
end
```

### All of the properties that are available to the rule resource is

| Property   | Type                            | Single/Multiple | Options                | Default | Description                                                                 | Examples                                                                                                                                                         |
| ---------- | ------------------------------- | --------------- | ---------------------- | ------- | --------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| every      | Symbol or Duration or TimeOfDay | Multiple        |                        |         | Period to execute rule                                                      | Symbol (:second, :minute, :hour, :day, :week, :month, :year) or duration (Integer.minutes, Integers.seconds, Integer.hours) or TimeOfDay.new(hour: 6, minute:30) | 
| cron       | String                          | Multiple        |                        |         | OpenHab Style Cron Expression                                               | '* * * * * * ?'                                                                                                                                                  |
| changed    | Item or Group or *Item Array[]* | Multiple        | from: State, to: State |         | Execute rule on item state change                                           | BedroomLightSwitch from: OFF to ON                                                                                                                               |
| *updated*  | Item or Group or *Item Array[]* | Multiple        |                        |         | Execute rule on item update                                                 | BedroomLightSwitch                                                                                                                                               |
| *command*  | Item or Group or *Item Array[]* | Multiple        | command:               |         | Execute rule on item command                                                | BedroomLightSwitch command: ON                                                                                                                                   |
| *channel*  | Channel                         | Mulitple        | event:                 |         | Execute rule on channel trigger                                             | astro_sun_home.rise_event, event: 'START'                                                                                                                        |
| *on_start* | Boolean                         | Single          |                        | false   | Execute rule on system start                                                | on_start                                                                                                                                                         |
| run        | Block passed event              | Multiple        |                        |         | Code to execute on rule trigger                                             |                                                                                                                                                                  |
| triggered  | Block passed item               | Multiple        |                        |         | Code with triggering item to execute on rule trigger                        |                                                                                                                                                                  |
| delay      | Duration                        | Multiple        |                        |         | Duration to wait between or after run blocks                                | delay 5.seconds                                                                                                                                                  |
| only_if    | Item or Item Array, or Block    | Multiple        |                        |         | Only execute rule if all supplied items are "On" and/or block returns true  | BedroomLightSwitch, BackyardLightSwitch or {BedroomLightSwitch.state == ON}                                                                                      |
| not_if     | Item or Item Array, or Block    | Multiple        |                        |         | Do **NOT** execute rule if any of the supplied items or blocks returns true | BedroomLightSwitch                                                                                                                                               |
| enabled    | Boolean                         | Single          |                        | true    | Enable or disable the rule from executing                                   |                                                                                                                                                                  |


Todo: Add a between property that only executes a rule between certain times of the day.

Todo: Add a for duration to changed

		
#### Property Values

##### Every

| Value             | Description                            | Example                            |
| ----------------- | -------------------------------------- | ---------------------------------- |
| :second           | Execute rule every second              | :second                            |
| :minute           | Execute rule very minute               | :minute                            |
| :hour             | Execute rule every hour                | :hour                              |
| :day              | Execute rule every day                 | :day                               |
| :week             | Execute rule every week                | :week                              |
| :month            | Execute rule every month               | :month                             |
| :year             | Execute rule one a year                | :year                              |
| [Integer].seconds | Execute a rule every X seconds         | 5.seconds                          |
| [Integer].minutes | Execute rule every X minutes           | 3.minutes                          |
| [Integer].hours   | Execute rule every X minutes           | 10.hours                           |
| TimeOfDay         | Execute rule at a specific time of day | TimeOfDay.new(hour: 6, minute: 30) | 




##### Changed
| Value | Description                                            | Example   |
| ----- | ------------------------------------------------------ | --------- |
| :from | Only execute rule if previous state matches from state | :from OFF |
| :to   | Only execute rule if new state matches from state      | :to ON          |


##### Channel
| Value  | Description                                                | Example        |
| ------ | ---------------------------------------------------------- | -------------- |
| :event | Only execute rule if this event was triggered from channel | :event 'START' | 
|        |                                                            |                |


#### Run
The run property is the automation code that is run when a rule is triggered.  This property accepts a block of code and executes it.  The block is automatically passed an event object which can be used to access multiple properties about the triggering event.

```
run { |event| }

or

run do |event| 

end


```

##### Event Properties
| Property | Description                      |
| -------- | -------------------------------- |
| item     | Triggering item                  |
| state    | Changed state of triggering item |
| last     | Last state of triggering item    | 


#### Triggered

#### Delay
The delay property is a non thread-blocking that is executed after, before, or between run blocks. 


### Items
Items can be directly accessed, compared, etc without any special accessors

| Method  | Description           | Example                     |
| ------- | --------------------- | --------------------------- |
| <<      | sends command to item | `VirtualSwich << ON`        |
| state = | sends command to item | `VirtualSwitch.state = ON`  |
| update  | send update to item   | `VirtualSwtich.update(OFF)` |


Besides the methods above, each item type has methods added to it to make it feel right within a ruby context.

#### SwitchItem
This class is aliased to **Switch** so you can compare compare item types using ` item.is_a? Switch`

| Method  | Description                               | Example                                         |
| ------- | ----------------------------------------- | ----------------------------------------------- |
| active? | Item is not undefined, not null and is ON | `puts "#{item.name} is active" if item.active?` |
| on      | Send command to turn item ON              | `item.on`                                       |
| off     | Send command to turn item OFF             | `item.off`                                      |
| on?     | Returns true if item state == ON          | `puts "#{item.name} is on." if item.on?`        |
| off?    | Returns true if item state == OFF         | `puts "#{item.name} is off." if item.off?`      |


#### DimmerItem
This class is aliased to **Dimmer** so you can compare compare item types using ` item.is_a? Dimmer`

| Method       | Parameters         | Description                               | Example                                         |
| ------------ | ------------------ | ----------------------------------------- | ----------------------------------------------- |
| active?      |                    | Item is not undefined, not null and is ON | `puts "#{item.name} is active" if item.active?` |
| on           |                    | Send command to turn item ON              | `item.on`                                       |
| off          |                    | Send command to turn item OFF             | `item.off`                                      |
| on?          |                    | Returns true if item state == ON          | `puts "#{item.name} is on." if item.on?`        |
| off?         |                    | Returns true if item state == OFF         | `puts "#{item.name} is off." if item.off?`      |
| dim, -=      | amount (default 1) | Dim the switch the specificed amount      | `DimmerSwitch.dim` or `DimmerSwitch -= 5`       |
| brighten, += | amount (default 1) | Brighten the switch the specificed amount | `DimmerSwitch.brighten` or `DimmerSwitch += 5`  |

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


### Groups

| Method                | Description                             |
| --------------------- | --------------------------------------- |
| groups                | Provides direct members that are groups | 
| * (ruby splat prefix) | Recursevly get all items in a group     |
| items                 | Alais for ruby splat                    |


```
rule 'Turn off any switch that changes' do
  changed *Switches
  triggered &:off
end
```

Is the same as

```
rule 'Turn off all Switches' do
   changed Switches.items
   run { | event | event.item.off }
end
```


			   

## Examples

### Log "Rule *name* excuted" an entry every minute

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

Which is the same as*
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

