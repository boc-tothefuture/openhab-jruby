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
object that is used by the [Every trigger]({{ site.baseurl }}{% link usage/triggers/every.md %}),
[delay]({%link usage/execution/delay.md %}), the [for option]({{ site.baseurl }}{% link usage/triggers/changed.md %}) and
[timers]({{ site.baseurl }}{% link usage/misc/timers.md %}). 

## Extended Methods

| Method                                              | Description                    | Examples              |
| --------------------------------------------------- | ------------------------------ | --------------------- |
| `hour` or `hours`                                   | Convert number to hours        | `1.hour`, `2.5 hours` |
| `minute` or `minutes`                               | Convert number to minutes      | `3.minutes`           |
| `second` or `seconds`                               | Convert number to seconds      | `5.seconds`           |
| `millis` or `millisecond` or `milliseconds` or `ms` | Convert number to milliseconds | `200.ms`              |


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