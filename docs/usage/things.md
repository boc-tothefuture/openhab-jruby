---
layout: default
title: Things
nav_order: 6
has_children: false
parent: Usage
has_toc: false
---

# Things

Things can be access using the `things` method and subsequent operations on that methods.

| Method             | Description                                                         |
| ------------------ | ------------------------------------------------------------------- |
| things             | Return all things as a Ruby Set                                     |
| []                 | Get a specific thing by name or ThingUID object                     |
| enumerable methods | All methods [here](https://ruby-doc.org/core-2.6.8/Enumerable.html) |

```ruby
things.each { |thing| logger.info("Thing: #{thing.uid}")}
logger.info("Thing: #{things['astro:sun:home'].uid}")
homie_things = things.select { |t| t.thing_type_uid == "mqtt:homie300" }
zwave_things = things.select { |t| t.binding_id == "zwave" }
homeseer_dimmers = zwave_things.select { |t| t.thing_type_uid.id == "homeseer_hswd200_00_000" }
things['zwave:device:512:node90'].uid.bridge_ids => ["512"]
things['mqtt:topic:4'].uid.bridge_ids => []
```

## Thing objects

The standard [JRuby alternate names and bean convention applies](https://github.com/jruby/jruby/wiki/CallingJavaFromJRuby#alternative-names-and-beans-convention), such that `getUID` becomes `uid`.

Actions are available via thing objects. For more details see [Actions]({{ site.baseurl }}{% link usage/misc/actions.md %})

Thing status is available through `status` method, which returns one of the values from [ThingStatus](https://www.openhab.org/docs/concepts/things.html#thing-status). Boolean methods are available based on this. 

| Method          | Description                                                               |
| --------------- | ------------------------------------------------------------------------- |
| `channels`      | Returns an array of channels, but also supports indexing by channel name. |
| `unitialized?`  | Returns true if the status is `UNINITIALIZED`                             |
| `initializing?` | Returns true if the status is `INITIALIZING`                              |
| `unknown?`      | Returns true if the status is `UNKNOWN`                                   |
| `online?`       | Returns true if the status is `ONLINE`                                    |
| `offline?`      | Returns true if the status is `OFFLINE`                                   |
| `removing?`     | Returns true if the status is `REMOVING`                                  |
| `removed?`      | Returns true if the status is `REMOVED`                                   |

```ruby
thing = things['chromecast:audiogroup:dd9f8622-eee-4eaf-b33f-cdcdcdeee001121']
logger.info("Audiogroup Status: #{thing&.status}")
logger.info("Audiogroup Online? #{thing&.online?}")
logger.info("Channel ids: #{thing.channels.map(&:uid)}")
logger.info("Items linked to volume channel: #{thing.channels['volume']&.items&.map(&:name)&.join(', ')}")
logger.info("Item linked to volume channel: #{thing.channels['volume']&.item&.name}")
```
