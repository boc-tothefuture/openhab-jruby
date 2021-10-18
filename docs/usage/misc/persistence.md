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

| Method            | Parameters                            | Return Value                | Example                                                         |
| ----------------- | ------------------------------------- | --------------------------- | --------------------------------------------------------------- |
| `persist`         | service                               | Nil                         | `Item1.persist`                                                 |
| `last_update`     | service                               | ZonedDateTime               | `Item1.last_update`                                             |
| `previous_state`  | skip_equal: (default: false), service | item state                  | `Item1.previous_state` `Item1.previous_state(skip_equal: true)` |
| `average_since`   | timestamp, service                    | DecimalType or QuantityType | `Item1.average_since(-1.hours, :influxdb)`                      |
| `changed_since`   | timestamp, service                    | boolean                     |                                                                 |
| `delta_since`     | timestamp, service                    | DecimalType or QuantityType |                                                                 |
| `deviation_since` | timestamp, service                    | DecimalType or QuantityType |                                                                 |
| `evolution_rate`  | timestamp, service                    | DecimalType                 |                                                                 |
| `historic_state`  | timestamp, service                    | HistoricState               |                                                                 |
| `maximum_since`   | timestamp, service                    | HistoricState               |                                                                 |
| `minimum_since`   | timestamp, service                    | HistoricState               |                                                                 |
| `sum_since`       | timestamp, service                    | DecimalType or QuantityType |                                                                 |
| `updated_since`   | timestamp, service                    | boolean                     |                                                                 |
| `variance_since`  | timestamp, service                    | DecimalType or QuantityType |                                                                 |

* The `timestamp` parameter accepts a java ZonedDateTime or a [Duration](../duration/) object that specifies how far back in time.
* The `service` optional parameter accepts the name of the persistence service to use, as a String or Symbol. When not specified, the system's default persistence service will be used.
* Dimensioned NumberItems will return a [QuantityType](../../items/number/#quantities) object
* `HistoricState` holds the item state and the timestamp data from OpenHAB's [HistoricItem](https://openhab.org/javadoc/latest/org/openhab/core/persistence/historicitem). It contains the following properties:
  * `timestamp` - a ZonedDateTime object indicating the timestamp of the persisted data
  * `state` - the state of the item persisted at the timestamp above. This will be a QuantityType for dimensioned NumberItem. It is not necessary to access the `state` property, as the HistoricState itself will return the state. See the example below.
  
  

### Examples:

Given the following items are configured to persist on every change:
```
Number        UV_Index
Number:Power  Power_Usage "Power Usage [%.2f W]"
```

```ruby
# UV_Index average will return a DecimalType
logger.info("UV_Index Average: #{UV_Index.average_since(12.hours)}") 
# Power_Usage has a Unit of Measurement, so 
# Power_Usage.average_since will return a QuantityType with the same unit
logger.info("Power_Usage Average: #{Power_Usage.average_since(12.hours)}") 
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

HistoricState

```ruby
max = Power_Usage.maximum_since(24.hours)
logger.info("Max power usage: #{max}, at: #{max.timestamp})
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
