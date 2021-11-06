---
layout: default
title: Duration
nav_order: 3
has_children: false
parent: Misc
grand_parent: Usage
---

# Duration
Ruby [integers](https://ruby-doc.org/core-2.6.8/Integer.html) and
[floats](https://ruby-doc.org/core-2.6.8/Float.html) are extended with several
methods to support durations. These methods create a new
[java.time.Duration](https://docs.oracle.com/en/java/javase/11/docs/api/java.base/java/time/Duration.html)
object that is used by the [Every trigger](../../triggers/every/),
[delay](../../execution/delay/), the [for option](../../triggers/changed/) and
[timers](../../misc/timers/). 

## Extended Methods

| Method                                      | Description                    |
| ------------------------------------------- | ------------------------------ |
| hour or hours                               | Convert number to hours        |
| minute or minutes                           | Convert number to minutes      |
| second or seconds                           | Convert number to seconds      |
| millis or millisecond or milliseconds or ms | Convert number to milliseconds |


## Examples

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