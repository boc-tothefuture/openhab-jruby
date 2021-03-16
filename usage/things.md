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
| enumerable methods | All methods [here](https://ruby-doc.org/core-2.5.0/Enumerable.html) |

```ruby
things.each { |thing| logger.info("Thing: #{thing.uid}")}
```

```ruby
logger.info("Thing: #{things['astro:sun:home'].uid}")
```

For thing objects now additional methods are provided, however the standard [JRuby alternate names and bean convention applies](https://github.com/jruby/jruby/wiki/CallingJavaFromJRuby#alternative-names-and-beans-convention), such that `getUID` becomes `uid`.

