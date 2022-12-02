---
layout: default
title: Time
has_children: false
parent: Misc
grand_parent: Usage
---

# Working With Time

Several options are available for time related code, including but not limited to:

* Ruby [Time](https://ruby-doc.org/core/Time.html) class
* Java [ZonedDateTime](https://docs.oracle.com/en/java/javase/11/docs/api/java.base/java/time/ZonedDateTime.html)
* Java [LocalTime](https://docs.oracle.com/en/java/javase/11/docs/api/java.base/java/time/LocalTime.html)
* [TimeOfDay]({{ site.baseurl }}{% link usage/misc/time_of_day.md %})
* Java [Duration]({{ site.baseurl }}{% link usage/misc/duration.md %})

## Ruby Time

The following methods are modified/added to Ruby Time:

| Method   | Description                                                                       |
| -------- | --------------------------------------------------------------------------------- |
| `+`      | Add a Numeric (seconds) or `Duration` and return the result as a Time object      |
| `-`      | Subtract a Numeric (seconds) or `Duration` and return the result as a Time object |
| `to_zdt` | Return a `ZonedDateTime` equivalent of the time object                            |

## Time Comparisons and Arithmetic

Comparisons and arithmetic can be done using the corresponding operators between Java and Ruby objects.

## Examples

```ruby
# Comparing localtime against TimeOfDay with `<`
max_time = Solar_Power.maximum_since(24.hours).timestamp.to_local_time
if max_time < NOON
  logger.info 'Max solar power happened before noon'
end

# Comparing Time against ZonedDateTime with `>`
sunset = things['astro:sun:home'].getEventTime('SUN_SET', nil, nil)
if Time.now > sunset 
  logger.info 'it is after sunset'
end

# Subtracting Duration from Time and comparing Time against ZonedDateTime
Motion_Sensor.last_update < Time.now - 10.minutes

# Using `-` operator with ZonedDateTime
# Comparing two ZonedDateTime using `<` 
Motion_Sensor.last_update < Light_Item.last_update - 10.minutes
# is the same as:
Motion_Sensor.last_update.before?(Light_Item.last_update.minus_minutes(10))
```
