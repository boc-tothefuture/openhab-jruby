---
layout: default
title: MonthDay
nav_order: 6
has_children: false
parent: Misc
grand_parent: Usage
---

# MonthDay

MonthDay class from [java.time.MonthDay](https://docs.oracle.com/en/java/javase/11/docs/api/java.base/java/time/MonthDay.html) can be used in rules for month-date related logic. Notable Methods:

| Method       | Parameter  | Description                                                                                                                                                                  |
| ------------ | ---------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --- |
| parse        | String     | Creates a MonthDay object with a given time string. The format is `[--]M-d`. Both the month and the date can be a one or two digit number, and optionally prefixed with `--` |
| now          |            | Creates a MonthDay object that represents the current month-day                                                                                                              |
| of           | month, day | Creates a MonthDay with the given month and day                                                                                                                              |
| month_value  |            | Returns the month part of the object as a number between 1 and 12                                                                                                            |     |
| month        |            | Returns the month part of the object as java.time.Month enum                                                                                                                 |
| day_of_month |            | Returns the second part of the object                                                                                                                                        |

For a full list of methods supported by MonthDay, please see the link above.

A MonthDay object can be compared against another MonthDay object or a parseable string representation of month-day.

## Examples

```ruby
#Create a MonthDay object
end_of_june = MonthDay.of(6, 30)

if MonthDay.now > end_of_june # comparing two MonthDay objects
  # do something
elsif MonthDay.now < '03-05' # comparison against a string representation for March 5th
  #do something
end
halloween = MonthDay.parse('10-31')
```

## between

`between` creates a MonthDay range that can be used to check if another MonthDay is within that range.

```ruby
logger.info("Within month-day range") if between('02-20'..'06-01').cover? MonthDay.now

case MonthDay.now

when between('01-01'..'03-31')
 logger.info("First quarter")
when between('04-01'..'06-30')
 logger.info("Second quarter")
end
```
