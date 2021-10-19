---
layout: default
title: Rules
nav_order: 1
has_children: false
parent: Usage
---


##  Rule Syntax
```ruby
require 'openhab'

rule 'name' do |<rule>|
   <zero or more triggers>
   <zero or more execution blocks>
   <zero or more guards>
end
```

### All of the properties that are available to the rule resource are

| Property         | Type                                                                    | Last/Multiple | Options                               | Default | Description                                                                 | Examples                                                                                                                                                                                                              |
| ---------------- | ----------------------------------------------------------------------- | ------------- | ------------------------------------- | ------- | --------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| description      | String                                                                  | Single        |                                       |         | Set the rule description                                                    |                                                                                                                                                                                                                       |
| every            | Symbol or Duration                                                      | Multiple      | at: String or TimeOfDay               |         | When to execute rule                                                        | Symbol (:second, :minute, :hour, :day, :week, :month, :year, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday) or duration (5.minutes, 20.seconds, 14.hours), at: '5:15' or TimeOfDay(h:5, m:15) |
| cron             | String                                                                  | Multiple      |                                       |         | OpenHAB Style Cron Expression                                               | '* * * * * * ?'                                                                                                                                                                                                       |
| changed          | Item or Item Array[] or Group or Group.members or Thing or Thing Array [] | Multiple      | from: State, to: State, for: Duration |         | Execute rule on item state change                                           | BedroomLightSwitch, from: OFF to ON                                                                                                                                                                                   |
| updated          | Item or Item Array[] or Group or Group.members or Thing or Thing Array [] | Multiple      | to: State                             |         | Execute rule on item update                                                 | BedroomLightSwitch, to: ON                                                                                                                                                                                            |
| received_command | Item or Item Array[] or Group or Group.members                          | Multiple      | command:                              |         | Execute rule on item command                                                | BedroomLightSwitch command: ON                                                                                                                                                                                        |
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

An optional variable can be provided to the block to access the rule configuration from within execution blocks and guards.

## Terse Rules

If you have a single trigger and execution block, you can use a terse rule:

```ruby
changed TestSwitch do |event|
  logger.info("TestSwitch changed to #{event.state}")
end
```

All parameters to the trigger are passed through, and an optional `name:` parameter is added:

```ruby
received_command TestSwitch, name: "My Test Switch Rule", command: ON do
  loogger.info("TestSwitch received command ON")
end
```
