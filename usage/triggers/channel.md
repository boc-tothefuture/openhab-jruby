---
layout: default
title: Channel
nav_order: 6
has_children: false
parent: Triggers
grand_parent: Usage
---

# channel

| Option    | Description                                                                   | Example                                                |
| --------- | ----------------------------------------------------------------------------- | ------------------------------------------------------ |
| triggered | Only execute rule if the event on the channel matches this/these event/events | `triggered: 'START' ` or `triggered: ['START','STOP']` |
| thing     | Thing for specified channels                                                  | `thing: 'astro:sun:home'`                              |

The channel trigger executes rule when a specific channel is triggered.  The syntax supports one or more channels with one or more triggers.   For `thing` is an optional parameter that makes it easier to set triggers on multiple channels on the same thing.


```ruby
rule 'Execute rule when channel is triggered' do
  channel 'astro:sun:home:rise#event'      
  run { logger.info("Channel triggered") }
end

# The above is the same as the below

rule 'Execute rule when channel is triggered' do
  channel 'rise#event', thing: 'astro:sun:home'   
  run { logger.info("Channel triggered") }
end

```

```ruby
rule 'Rule provides access to channel trigger events in run block' do
  channel 'astro:sun:home:rise#event', triggered: 'START'
  run { |trigger| logger.info("Channel(#{trigger.channel}) triggered event: #{trigger.event}") }
end
```

```ruby
rule 'Rules support multiple channels' do
  channel ['rise#event','set#event'], thing: 'astro:sun:home' 
  run { logger.info("Channel triggered") }
end
```

```ruby
rule 'Rules support multiple channels and triggers' do
  channel ['rise#event','set#event'], thing: 'astro:sun:home', triggered: ['START', 'STOP'] 
  run { logger.info("Channel triggered") }
end
```
