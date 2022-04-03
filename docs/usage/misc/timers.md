---
layout: default
title: Timers
nav_order: 4
has_children: false
parent: Misc
grand_parent: Usage
---

# Timers

Timers are created using the `after` method. `create_timer` is an alias to `after` for compatibility reasons.

After method parameters

| Parameter | Description                                                                                                                                                          |
| --------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| time      | Accepts a [Duration]({{ site.baseurl }}{% link usage/misc/duration.md %}), Ruby [Time](https://ruby-doc.org/core-2.6.3/Time.html), or Java `ZonedDateTime` for timer |
| id        | Optional object that is used to identify the timer                                                                                                                   |
| block     | Block to execute after duration, block will be passed timer object                                                                                                   |

Timers with an id are reentrant, by id and block. Reentrant means that when the same id and block are encountered the timer is rescheduled rather than creating a second new timer.

## Timer Object

The timer object has all of the methods of the [OpenHAB Timer](https://www.openhab.org/docs/configuration/actions.html#timers) with a change to the reschedule method to enable it to operate Ruby context. The following methods are available to a Timer object:

| Method           | Parameter | Description                                                                                        |
| ---------------- | --------- | -------------------------------------------------------------------------------------------------- |
| `cancel`         |           | Cancel the scheduled timer                                                                         |
| `execution_time` |           | An alias for `Timer::getExecutionTime()`. Available in OpenHAB 3.1+                                |
| `reschedule`     | duration  | Optional [duration](#Duration) if unspecified original duration supplied to `after` method is used |
| `active?`        |           | An alias for `Timer::isActive()`                                                                   |
| `cancelled?`     |           | An alias for `Timer::isCancelled()`. Available in OpenHAB 3.2+                                     |
| `running?`       |           | An alias for `Timer::isRunning()`                                                                  |
| `terminated?`    |           | An alias for `Timer::hasTerminated()`                                                              |

### Examples

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

Timers with an `id` can be accessed via the `timers[id]` method. This method returns a set of timers associated with that id. Cancelling the timer(s) with the given `id` can be done by calling `timers[id]&.each(&:cancel)` or by using the shorthand `timers[id]&.cancel_all`.

```ruby
# Reentrant timers will automatically reschedule if same block is encountered again with same reentrant object
rule 'Turn on light for 10 minutes when a closet door is open' do
  changed ClosetDoors.members, to: OPEN
  triggered do |item|
    after 10.minutes, id: item do
      light_for_closet(item).ensure.off
    end
  end
end

rule 'Turn off light when a closet door is closed' do
  changed ClosetDoors.members, to: CLOSED
  triggered { |item| light_for_closet(item).off}
end
```

```ruby
# Timers can be canceled by looking up timer ID and canceling all timers associated with that ID
after 3.seconds, :id => :foo do
  logger.info "Timer Fired"
end

rule 'Cancel timer' do
  run { timers[:foo]&.cancel_all }
  on_start true
end
```

See also: [Changed Duration]({{ site.baseurl }}{% link usage/triggers/changed.md %}#changed-duration), [Timed Commands]({{ site.baseurl }}{% link usage/items/index.md %}#timed-commands)