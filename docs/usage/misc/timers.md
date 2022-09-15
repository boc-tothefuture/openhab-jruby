---
layout: default
title: Timers
nav_order: 5
has_children: false
parent: Misc
grand_parent: Usage
---

# Timers

Timers are created using the `after` method. Its parameters are:

| Parameter | Description                                                                                                                                                          |
| --------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| time      | Accepts a [Duration]({{ site.baseurl }}{% link usage/misc/duration.md %}), Ruby [Time](https://ruby-doc.org/core-2.6.3/Time.html), or Java `ZonedDateTime` for timer |
| id        | Optional object that is used to identify the timer which also makes the timer [reentrant](#reentrant-timers).                                                        |
| block     | Block to execute after duration, block will be passed timer object                                                                                                   |

Note: `create_timer` is an alias to `after` for compatibility reasons.

## Timer Object

The timer object has all of the methods of the [OpenHAB Timer](https://www.openhab.org/docs/configuration/actions.html#timers) with a change 
to the reschedule method to enable it to operate Ruby context. The following methods are available to a Timer object:

| Method           | Parameter | Description                                                                                        |
| ---------------- | --------- | -------------------------------------------------------------------------------------------------- |
| `cancel`         |           | Cancel the scheduled timer                                                                         |
| `execution_time` |           | An alias for `Timer::getExecutionTime()`. Available in OpenHAB 3.1+                                |
| `reschedule`     | duration  | Optional [duration](#Duration) if unspecified original duration supplied to `after` method is used |
| `active?`        |           | An alias for `Timer::isActive()`                                                                   |
| `cancelled?`     |           | An alias for `Timer::isCancelled()`. Available in OpenHAB 3.2+                                     |
| `running?`       |           | An alias for `Timer::isRunning()`                                                                  |
| `terminated?`    |           | An alias for `Timer::hasTerminated()`                                                              |

## Examples

```ruby
after 5.seconds do
  logger.info("Timer Fired")
end
```

```ruby
# An item can be the duration for a timer, the value will be interpreted as seconds
MyNumericItem << 3

after MyNumericItem do
  logger.info("Timer Fired after 3 seconds")
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

```ruby
# If the duration is an item, it will be reevaluated on reschedule
MyNumericItem << 3

after MyNumericItem do |timer|
  logger.info("Timer Fired after 3 seconds")

  MyNumericItem << 6 # could be changed anywhere, not only in timer's block

  # rescheduled timer will fire after 6 seconds
  timer.reschedule
end
```

```ruby
# Timers can be manipulated through the returned object
mytimer = after 1.minute do
  logger.info('It has been 1 minute')
end

mytimer.cancel
```

## Reentrant Timers

Timers with an id are reentrant, by id and block. Reentrant means that when the same id and block are encountered, 
the timer is rescheduled rather than creating a second new timer.

This removes the need for the usual boilerplate code to manually keep track of timer objects.

```ruby
# Reentrant timers will automatically reschedule if same block is encountered again
rule 'Turn off closet light after 10 minutes' do
  changed ClosetLights.members, to: ON
  triggered do |item|
    after 10.minutes, id: item do
      item.ensure.off
    end
  end
end
```

## Managing Timers with `id`

Timers with `id` can be managed with the built-in `timers[id]` method. Multiple timer blocks can share the same `id`, which is
why `timers[id]` returns a `TimerSet` object. It is a descendant of `Set` and it contains a set of timers associated with that id.

`TimerSet` has the following methods in addition to the ones inherited from [Set](https://ruby-doc.org/stdlib-2.6.8/libdoc/set/rdoc/Set.html):

| Method       | Description                                                                                                       |
| ------------ | ----------------------------------------------------------------------------------------------------------------- |
| `cancel`     | Cancel all timers in the set. Example: `timers[id]&.cancel`. This is a shorthand for `timers[id]&.each(&:cancel)` |
| `reschedule` | Reschedule all timers in the set. Accepts an optional `duration` argument to specify a different duration.        |

When a timer is cancelled, it will be removed from the set. Once the set is empty, it will be removed from `timers[]` hash and
`timers[id]` will return nil.

```ruby
# Timers with id can be managed through the built-in timers[] hash
after 1.minute, :id => :foo do
  logger.info('managed timer has fired')
end

timers[:foo]&.cancel

if !timers[:foo]
  logger.info('The timer :foo is not active')
end
```

See also: [Changed Duration]({{ site.baseurl }}{% link usage/triggers/changed.md %}#changed-duration), [Timed Commands]({{ site.baseurl }}{% link usage/items/index.md %}#timed-commands)