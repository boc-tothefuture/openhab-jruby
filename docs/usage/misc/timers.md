---
layout: default
title: Timers
nav_order: 4
has_children: false
parent: Misc
grand_parent: Usage
---

# Timers
Timers are created using the `after` method. 

After method parameters

| Parameter | Description                                                        |
| --------- | ------------------------------------------------------------------ |
| duration  | Duration for timer                                                 |
| block     | Block to execute after duration, block will be passed timer object |

Timer Object
The timer object has all of the methods of the [OpenHAB Timer](https://www.openhab.org/docs/configuration/actions.html#timers) with a change to the reschedule method to enable it to operate Ruby context. The following methods are available to a Timer object:

| Method           | Parameter | Description                                                                                        |
| ---------------- | --------- | -------------------------------------------------------------------------------------------------- |
| `cancel`         |           | Cancel the scheduled timer                                                                         |
| `execution_time` |           | An alias for `Timer::getExecutionTime()`. Available in OpenHAB 3.1+                                |
| `reschedule`     | duration  | Optional [duration](#Duration) if unspecified original duration supplied to `after` method is used |
| `active?`        |           | An alias for `Timer::isActive()`                                                                   |
| `running?`       |           | An alias for `Timer::isRunning()`                                                                  |
| `terminated?`    |           | An alias for `Timer::hasTerminated()`                                                              |

```ruby
after 5.seconds do
  logger.info("Timer Fired")
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
# Timers can be manipulated through the returned object
mytimer = after 1.minute do
  logger.info('It has been 1 minute')
end

mytimer.cancel
```
