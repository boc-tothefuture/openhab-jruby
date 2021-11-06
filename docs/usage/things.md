---
layout: default
title: Things
nav_order: 5
has_children: false
parent: Usage
has_toc: false
---

# Things

Things can be access using the `things` method and subsequent operations on that methods. 

| Method             | Description                                                         |
| ------------------ | ------------------------------------------------------------------- |
| things             | Return all things as a Ruby Set                                     |
| []                 | Get a specific thing by name                                        |
| enumerable methods | All methods [here](https://ruby-doc.org/core-2.6.8/Enumerable.html) |

```ruby
things.each { |thing| logger.info("Thing: #{thing.uid}")}
```

```ruby
logger.info("Thing: #{things['astro:sun:home'].uid}")
```

## Thing objects

The standard [JRuby alternate names and bean convention applies](https://github.com/jruby/jruby/wiki/CallingJavaFromJRuby#alternative-names-and-beans-convention), such that `getUID` becomes `uid`.

Actions are available via thing objects. For more details see [Actions](../misc/actions/)

Thing status is available through `status` method, which returns one of the values from [ThingStatus](https://www.openhab.org/docs/concepts/things.html#thing-status). Boolean methods are available based on this. 

| Method          | Description                                   |
| --------------- | --------------------------------------------- |
| `unitialized?`  | Returns true if the status is `UNINITIALIZED` |
| `initializing?` | Returns true if the status is `INITIALIZING`  |
| `unknown?`      | Returns true if the status is `UNKNOWN`       |
| `online?`       | Returns true if the status is `ONLINE`        |
| `offline?`      | Returns true if the status is `OFFLINE`       |
| `removing?`     | Returns true if the status is `REMOVING`      |
| `removed?`      | Returns true if the status is `REMOVED`       |

```ruby
logger.info("Audiogroup Status: #{things['chromecast:audiogroup:dd9f8622-eee-4eaf-b33f-cdcdcdeee001121']&.status}")
logger.info("Audiogroup Online? #{things['chromecast:audiogroup:dd9f8622-eee-4eaf-b33f-cdcdcdeee001121']&.online?}")
```
