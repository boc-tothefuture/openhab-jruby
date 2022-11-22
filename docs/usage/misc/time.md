# @title Working With Time

# Working With Time

Several options are available for time related code, including but not limited to:

* Java {LocalDate} - represents a date with no time
* Java {LocalTime} - represents a time with no date
* Java {Month}
* Java {MonthDay} - represents a date with no time or year
* Java {ZonedDateTime} - represents a specific instance with a date and time
* Java {Duration}
* Java {Period}
* Ruby [Date](https://ruby-doc.org/stdlib-2.6.8/libdoc/date/rdoc/Date.html) - represents a date with no time
* Ruby [Time](https://ruby-doc.org/core/Time.html) - represents a specific instant with a date and time
* Ruby [DateTime](https://ruby-doc.org/core/DateTime.html) - represents a specific instant with a date and time

## Durations

Ruby [integers](https://ruby-doc.org/core-2.6.8/Integer.html) and
[floats](https://ruby-doc.org/core-2.6.8/Float.html) are extended with several
methods to support durations. These methods create a new {Duration} or {Period}
object that is used by the {OpenHAB::DSL::Rules::BuilderDSL#every every} trigger,
{OpenHAB::DSL::Rules::BuilderDSL#delay delay} block, the for option of
{OpenHAB::DSL::Rules::BuilderDSL#changed changed} triggers, and
{OpenHAB::Core::Timer timers}.


### Examples

```ruby
rule 'run every 30 seconds' do
  every 30.seconds
  run { logger.info('Hello') }
end
```

```ruby
rule 'Warn about open door' do
  changed FrontDoor, to: OPEN, for: 10.minutes
  run { |event| logger.info("#{event.item.name} has been open for 10 minutes") }
end
```

```ruby
rule 'Timer example' do
  on_start
  run do
    after(3.hours) { logger.info('3 hours have passed') }
  end
end
```

## Time Comparisons, Conversions, and Arithmetic

Comparisons, conversions and arithmetic are automatic between Java and Ruby types.
Note that anytime you do a comparison between a type with more specific data, and
a type missing specific data, the comparison is done as if the more specific data
is at the beginning of its period. I.e. comparing a time to a month, the month
will be treated as 00:00:00 on the first day of the month. When comparing with
a type that's missing more generic data, it will be filled in from the other object.
I.e. comparing a time to a month, the month will be assumed to be in the same year
as the time.

### Examples

```ruby
# Comparing ZonedDateTime against LocalTime with `<`
max_time = Solar_Power.maximum_since(24.hours.ago)
if max_time < LocalTime::NOON
  logger.info 'Max solar power happened before noon'
end

# Comparing Time against ZonedDateTime with `>`
sunset = things['astro:sun:home'].get_event_time('SUN_SET', nil, nil)
if Time.now > sunset 
  logger.info 'it is after sunset'
end

# Subtracting Duration from Time and comparing Time against ZonedDateTime
Motion_Sensor.last_update < Time.now - 10.minutes
# Alternatively:
Motion_Sensor.last_update < 10.minutes.ago

# Finding The Duration Between Two Times
elapsed_time = Time.now - Motion_Sensor.last_update
# Alternatively:
elapsed_time = ZonedDateTime.now - Motion_Sensor.last_update

# Using `-` operator with ZonedDateTime
# Comparing two ZonedDateTime using `<` 
Motion_Sensor.last_update < Light_Item.last_update - 10.minutes
# is the same as:
Motion_Sensor.last_update.before?(Light_Item.last_update.minus_minutes(10))
```

## Ranges

Ranges of date time objects work as expected. Make sure to use `#cover?`
instead of `#include?` to do a simple comparison, instead of generating
an array and searching it linearly.

Ranges of non-absolute, "circular" types ({LocalTime}, {Month}, {MonthDay})
are smart enough to automatically handle boundary issues.

Coarse types (like {LocalDate}, {Month}, {MonthDay}) will also work correctly when checking
against a more specific type.

To easily parse strings into date-time ranges, use the {between}
helper.

### Examples

```ruby
between('10:00'..'14:00').cover?(Time.now)
between('11pm'..'1am').cover?(Time.now)
Time.now < LocalTime::NOON
 
case Time.now
when between('6:00'...'12:00')
  logger.info("Morning Time")
when between('12:00'..'15:00')
  logger.info("Afternoon")
else
  logger.info("Not in time range")
end

(java.time.Month::NOVEMBER..java.time.Month::DECEMBER).cover?(Time.now)
(java.time.Month::NOVEMBER..java.time.Month::DECEMBER).cover?(Date.today)
```
