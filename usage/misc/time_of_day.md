---
layout: default
title: TimeOfDay
nav_order: 5
has_children: false
parent: Misc
grand_parent: Usage
---

# TimeOfDay

TimeOfDay class can be used in rules for time related logic. Methods:

| Method      | Parameter      | Description                                                                                                                                             | Example                                                                                                                                                      |
| ----------- | -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| parse       | String         | Creates a TimeOfDay object with a given time string. The format is hh[:mm[:ss]][am\|pm]. When am/pm is not specified, the time should be in 24h format. | curfew_start = TimeOfDay.parse '19:30' => 19:30<br/>TimeOfDay.parse '2pm' => 14:00<br/> TimeOfDay.parse '12:30am' => 00:30<br/>TimeOfDay.parse '15' => 15:00 |
| now         |                | Creates a TimeOfDay object that represents the current time                                                                                             | TimeOfDay.now > curfew_start, or TimeOfDay.now > '19:30'                                                                                                     |
| MIDNIGHT    |                | Creates a TimeOfDay object for 00:00                                                                                                                    | TimeOfDay.MIDNIGHT                                                                                                                                           |
| NOON        |                | Creates a TimeOfDay object for 12:00                                                                                                                    | TimeOfDay.now < TimeOfDay.NOON                                                                                                                               |
| constructor | h, m, s        | Creates a TimeOfDay with the given hour, minute, second                                                                                                 | TimeOfDay.new(h: 17, m: 30, s: 0)                                                                                                                            |
| hour        |                | Returns the hour part of the object                                                                                                                     | TimeOfDay.now.hour                                                                                                                                           |
| minute      |                | Returns the minute part of the object                                                                                                                   | TimeOfDay.now.minute                                                                                                                                         |
| second      |                | Returns the second part of the object                                                                                                                   | TimeOfDay.now.second                                                                                                                                         |
| between?    | TimeOfDayRange | Returns true if it falls within the given time range                                                                                                    | TimeOfDay.now.between? '3pm'..'7pm'                                                                                                                          |


A TimeOfDay object can be compared against another TimeOfDay object or a parseable string representation of time.

Note: the following global constants are available:
| Name     | Description |
| -------- | ----------- |
| MIDNIGHT | 00:00       |
| NOON     | 12:00       |


## Examples

```ruby
#Create a TimeOfDay object
break_time = NOON

if TimeOfDay.now > TimeOfDay.new(h: 17, m: 30, s: 0) # comparing two TimeOfDay objects
  # do something
elsif TimeOfDay.now < '8:30' # comparison against a string
  #do something
end
four_pm = TimeOfDay.parse '16:00'
```

## between
 
 `between` creates a TimeOfDay range that can be used to check if another Time, TimeOfDay, or [TimeOfDay parsable string](#TimeOfDay) is within that range. 
 
 ```ruby
 logger.info("Within time range") if between('10:00'..'14:00').cover? Time.now
 logger.info("Within time range") if between('10:00'..'14:00').include? TimeOfDay.now
 
case Time.now

when between('6:00'...'12:00')
  logger.info("Morning Time")
when between('12:00'..'15:00')
  logger.info("Afternoon")
else
  logger.info("Not in time range")
end  
 ```
 
 