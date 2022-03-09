---
layout: default
title: Channel
nav_order: 6
has_children: false
parent: Triggers
grand_parent: Usage
---

# channel

The channel trigger executes rule when a specific channel is triggered. The syntax supports one or more channels with one or more triggers.
`thing` is an optional parameter that makes it easier to set triggers on multiple channels on the same thing.

| Option       | Description                                                                   | Example                                                |
| ------------ | ----------------------------------------------------------------------------- | ------------------------------------------------------ |
| `triggered:` | Only execute rule if the event on the channel matches this/these event/events | `triggered: 'START' ` or `triggered: ['START','STOP']` |
| `thing:`     | Thing for specified channels                                                  | `thing: 'astro:sun:home'`                              |


## Examples

```ruby
rule 'Execute rule when channel is triggered' do
  channel 'astro:sun:home:rise#event'      
  run { logger.info("Channel triggered") }
end

# The above is the same as each of the below

rule 'Execute rule when channel is triggered' do
  channel 'rise#event', thing: 'astro:sun:home'   
  run { logger.info("Channel triggered") }
end

rule 'Execute rule when channel is triggered' do
  channel 'rise#event', thing: things['astro:sun:home']
  run { logger.info("Channel triggered") }
end

rule 'Execute rule when channel is triggered' do
  channel 'rise#event', thing: things['astro:sun:home'].uid
  run { logger.info("Channel triggered") }
end

rule 'Execute rule when channel is triggered' do
  channel 'rise#event', thing: ['astro:sun:home']
  run { logger.info("Channel triggered") }
end

rule 'Execute rule when channel is triggered' do
  channel things['astro:sun:home'].channels['rise#event']
  run { logger.info("Channel triggered") }
end

rule 'Execute rule when channel is triggered' do
  channel things['astro:sun:home'].channels['rise#event'].uid
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

```ruby
rule 'Rules support multiple things' do
  channel 'keypad#code', thing: ['mqtt:homie300:keypad1', 'mqtt:homie300:keypad1']
  run { logger.info("Channel triggered") }
end
```
