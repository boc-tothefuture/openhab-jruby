---
layout: default
title: Triggers
nav_order: 2
has_children: true
parent: Usage
---

# Triggers

Triggers specify what will cause the execution blocks to run. Multiple triggers can be defined within the same rule. This section only applies to file-based rules. Triggers for UI-based rules are specified through the UI.

## Trigger Attachments

All triggers support event attachments that enable the association of an object to a trigger.

| Method | Description                   | example                       |
| ------ | ----------------------------- | ----------------------------- |
| attach | attach an object to a trigger | changed Switch, attach: 'foo' |

This enables one to use the same rule and take different actions if the trigger is different. The attached object is passed to the execution block through the `event.attachment` accessor.

Note: The trigger attachment feature is not available for UI rules.

## Example

```ruby
rule 'Set Dark switch at sunrise and sunset' do
  channel 'astro:sun:home:rise#event', attach: OFF
  channel 'astro:sun:home:set#event', attach: ON
  run { |event| Dark << event.attachment }
end
```
