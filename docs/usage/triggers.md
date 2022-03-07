---
layout: default
title: Triggers
nav_order: 2
has_children: true
parent: Usage
---

# Trigger Attachments

All triggers support event attachments that enable the association of an object to a trigger.

| Method | Description                   | example                       |
|--------|-------------------------------|-------------------------------|
| attach | attach an object to a trigger | changed Switch, attach: 'foo' |

This enables one to use the same rule and take different actions if the trigger is different. 

The attached object is then available on the event object with by the 'attachment' accessor.

Note: The trigger attachment feature is not available for UI rules.

## Example

```ruby
rule 'Set Dark switch at sunrise and sunset' do
  channel 'astro:sun:home:rise#event', attach: OFF
  channel 'astro:sun:home:set#event', attach: ON
  run { |event| Dark << event.attachment }
end
```

