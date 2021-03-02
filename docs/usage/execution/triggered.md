---
layout: default
title: Triggered
nav_order: 2
has_children: false
parent: Execution Blocks
grand_parent: Usage
---

# Triggered
This property is the same as the run property except rather than passing an event object to the automation block the triggered item is passed. This enables optimizations for simple cases and supports ruby's [pretzel colon `&:` operator.](https://medium.com/@dcjones/the-pretzel-colon-75df46dde0c7) 

## Examples
```ruby
rule 'Triggered has access directly to item triggered' do
  changed TestSwitch
  triggered { |item| logger.info("#{item.id} triggered") }
end

```

Triggered items are highly useful when working with groups
```ruby
#Switches is a group of Switch items

rule 'Triggered item is item changed when a group item is changed.' do
  changed Switches.members
  triggered { |item| logger.info("Switch #{item.id} changed to #{item}")}
end


rule 'Turn off any switch that changes' do
  changed Switches.members
  triggered(&:off)
end

```

Like other execution blocks, multiple triggered blocks are supported in a single rule
```ruby
rule 'Turn a switch off and log it, 5 seconds after turning it on' do
  changed Switches.members, to: ON
  delay 5.seconds
  triggered(&:off)
  triggered {|item| logger.info("#{item.label} turned off") }
end
```

