---
layout: default
title: DateTimeItem
nav_order: 6
has_children: false
parent: Items
grand_parent: Usage
---

# DateTimeItem

DateTime items are extended with a lot of methods that make working with them easy. Most of the methods
defined by the [ruby Time class](https://ruby-doc.org/core-2.6.8/Time.html) are available, and some of 
them are extended or adapted with OpenHAB specific functionality.

##### Examples

DateTime items can be updated and commanded with ruby Time objects

```ruby
Example_DateTimeItem << Time.now
```

Math operations (+ and -) are available to make calculations with time in a few different ways

```ruby
Example_DateTimeItem + 600 # Number of seconds
Example_DateTimeItem - '01:15' # Subtracts 1h 15 min
Example_DateTimeItem + 2.hours # Use the helper library's duration methods

Example_DateTimeItem - Example_DateTimeItem2 # Calculate the time difference, in seconds
Example_DateTimeItem - '2021-01-01 15:40' # Calculates time difference
```

Comparisons between different time objects can be performed

```ruby
Example_DateTimeItem == Example_DateTimeItem2 # Equality, works across time zones
Example_DateTimeItem > '2021-01-31' # After midnight jan 31st 2021
Example_DateTimeItem <= Time.now # Before or equal to now
Example_DateTimeItem < TimeOfDay.noon # Before noon
```

TimeOfDay ranges created with the `between` method also works

```ruby
case Example_DateTimeItem
when between('00:00'...'08:00')
  logger.info('Example_DateTimeItem is between 00:00..08:00')
when between('08:00'...'16:00')
  logger.info('Example_DateTimeItem is between 08:00..16:00')
when between('16:00'..'23:59')
  logger.info('Example_DateTimeItem is between 16:00...23:59')
end
```
