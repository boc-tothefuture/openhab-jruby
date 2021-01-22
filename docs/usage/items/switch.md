---
layout: default
title: Switch
nav_order: 1
has_children: false
parent: Items
grand_parent: Usage
---


# Switch Item
This class is aliased to **Switch** so you can compare compare item types using ` item.is_a? Switch or grep(Switch)`

| Method  | Description                                  | Example                                         |
| ------- | -------------------------------------------- | ----------------------------------------------- |
| truthy? | Item is not undefined, not null and is ON    | `puts "#{item.name} is truthy" if item.truthy?` |
| on      | Send command to turn item ON                 | `item.on`                                       |
| off     | Send command to turn item OFF                | `item.off`                                      |
| on?     | Returns true if item state == ON             | `puts "#{item.name} is on." if item.on?`        |
| off?    | Returns true if item state == OFF            | `puts "#{item.name} is off." if item.off?`      |
| toggle  | Send command to invert the state of the item | `item.toggle`                                   |
| !       | Return the inverted state of the item        | `item << !item`                                 |


Switches respond to `on`, `off`, and `toggle`

```ruby
# Turn on all switches in a group called Switches
Switches.each(&:on)
```

Check state with `off?` and `on?`

```ruby
# Turn on all switches in a group called Switches that are off
Switches.select(&:off?).each(&:on)
```

Switches can be selected in an enumerable with grep.

```ruby
items.grep(Switch)
     .each { |switch| logger.info("Switch #{switch.id} found") }
```

Switch states also work in grep.
```ruby
# Log all switch items set to ON
items.grep(Switch)
     .grep(ON)
     .each { |switch| logger.info("#{switch.id} ON") }

# Log all switch items set to OFF
items.grep(Switch)
     .grep(OFF)
     .each { |switch| logger.info("#{switch.id} OFF") }
```

Switch states also work in case statements.
```ruby
items.grep(Switch)
     .each do |switch|
        case switch
        when ON
          logger.info("#{switch.id} ON")
        when OFF
          logger.info("#{switch.id} OFF")
         end
      end
```


Other examples
```ruby
# Invert all switches
items.grep(Switch)
     .each { |item| if item.off? then item.on else item.off end}

# Or using not operator

items.grep(Switch)
     .each { |item| item << !item } 

```

