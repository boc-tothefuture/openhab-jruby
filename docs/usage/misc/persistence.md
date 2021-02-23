---
layout: default
title: Persistence
nav_order: 2
has_children: false
parent: Misc
grand_parent: Usage
---

# Persistence

[Persistence](https://www.openhab.org/docs/configuration/persistence.html) functions can be accessed through the item object. The following methods related to persistence are available: 

| Method            | Parameters                            | Example                                                         |
| ----------------- | ------------------------------------- | --------------------------------------------------------------- |
| `persist`         | service                               | `Item1.persist`                                                 |
| `last_update`     | service                               | `Item1.last_update`                                             |
| `previous_state`  | skip_equal: (default: false), service | `Item1.previous_state` `Item1.previous_state(skip_equal: true)` |
| `average_since`   | timestamp, service                    | `Item1.average_since(-1.hours, :influxdb)`                      |
| `changed_since`   | timestamp, service                    |                                                                 |
| `delta_since`     | timestamp, service                    |                                                                 |
| `deviation_since` | timestamp, service                    |                                                                 |
| `evolution_rate`  | timestamp, service                    |                                                                 |
| `historic_state`  | timestamp, service                    |                                                                 |
| `maximum_since`   | timestamp, service                    |                                                                 |
| `minimum_since`   | timestamp, service                    |                                                                 |
| `sum_since`       | timestamp, service                    |                                                                 |
| `updated_since`   | timestamp, service                    |                                                                 |
| `variance_since`  | timestamp, service                    |                                                                 |

* The `timestamp` parameter accepts a java ZonedDateTime or a [Duration](../duration/) object that specifies how far back in time.
* The `service` optional parameter accepts the name of the persistence service to use, as a String or Symbol. When not specified, the system's default persistence service will be used.
* The return value of the following persistence methods is a [Quantity](../../items/number/#quantities) when the corresponding item is a dimensioned NumberItem:
  * `average_since`
  * `delta_since`
  * `deviation_since`
  * `sum_since`
  * `variance_since`

### Examples:

Given the following items are configured to persist on every change:
```
Number        UV_Index
Number:Power  Power_Usage "Power Usage [%.2f W]"
```

```ruby
# UV_Index average will return a DecimalType
logger.info("UV_Index Average: #{UV_Index.average_since(12.hours, :influxdb)}") 
# Power_Usage has a Unit of Measurement, so 
# Power_Usage.average_since will return a Quantity with the same unit
logger.info("Power_Usage Average: #{Power_Usage.average_since(12.hours, :influxdb)}") 
```

Comparison using Quantity

```ruby
# Because Power_Usage has a unit, the return value 
# from average_since is a Quantity which can be
# compared against a string with quantity
if Power_Usage.average_since(15.minutes) > '5 kW'
  logger.info("The power usage exceeded its 15 min average)
end
```

## Persistence Block

A persistence block can group multiple persistence operations together under a single service. For example, instead of:

```ruby
Item1.persist(:influxdb)
Item1.changed_since(1.hour, :influxdb)
Item1.average_since(12.hours, :influxdb)
```

Using a persistence block:

```ruby
persistence(:influxdb) do
  Item1.persist
  Item1.changed_since(1.hour)
  Item1.average_since(12.hours)
end
```

## Setting The Default Persistence Service

The default persistence service can be set at the beginning of the execution block (run, triggered, otherwise), and it will affect all persistence operations within that block, unless a specific service is specified in the argument or within a persistence block.

Note that this does not alter the system-wide default persistence service that is configured 
on the OpenHAB installation. This simply affects the current execution block.

To specify the default persistence service, call the `def_default_persistence` function at the beginning
of the execution block. Example:

```ruby
require 'openhab'

rule 'Test rule' do
  on_start
  run do
    def_default_persistence :influxdb
    logger.info("Item1's last_update: #{Item1.last_update}") 
  end
end
```
