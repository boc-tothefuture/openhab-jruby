---
layout: default
title: Items
nav_order: 4
has_children: true
parent: Usage
---


# Items
Items can be directly accessed, compared, etc, without any special accessors. You may use the item name anywhere within the code and it will automatically be loaded.

All items can be accessed as an enumerable the `items` method. 

| Method             | Description                                                                    |
| ------------------ | ------------------------------------------------------------------------------ |
| []                 | Get a specific item by name, this syntax can be used to dynamically load items |
| enumerable methods | All methods [here](https://ruby-doc.org/core-2.5.0/Enumerable.html)            |

## Examples

Item Definition
```
Dimmer DimmerTest "Test Dimmer"
Switch SwitchTest "Test Switch"

```

```ruby
logger.info("Item Count: #{items.count}")  # Item Count: 2
logger.info("Items: #{items.sort_by(&:label).map(&:label).join(', ')}")  #Items: Test Dimmer, Test Switch' 
```

```ruby
rule 'Use dynamic item lookup to increase related dimmer brightness when switch is turned on' do
  changed SwitchTest, to: ON
  triggered { |item| items[item.name.gsub('Switch','Dimmer')].brighten(10) }
end
```

## All Items
Item types have methods added to them to make it flow naturally within the a ruby context.  All methods of the OpenHAB item are available plus the additional methods described below.


| Method  | Description                                       | Example                                                      |
| ------- | ------------------------------------------------- | ------------------------------------------------------------ |
| <<      | Sends command to item                             | `VirtualSwich << ON`                                         |
| command | alias for shovel operator (<<)                    | `VirtualSwich.command(ON)`                                   |
| update  | Sends update to an item                           | `VirtualSwitch.update(ON)`                                   |
| id      | Returns label or item name if no label            | `logger.info(#{item.id})`                                    |
| undef?  | Returns true if the state of the item is UNDEF    | `logger.info("SwitchTest is UNDEF") if SwitchTest.undef?`    |
| null?   | Returns true if the state of the item is NULL     | `logger.info("SwitchTest is NULL") if SwitchTest.null?`      |
| state?  | Returns true if the state is not UNDEF or NULL    | `logger.info("SwitchTest has a state") if SwitchTest.state?` |
| state   | Returns state of the item or nil if UNDEF or NULL | `logger.info("SwitchTest state #{SwitchTest.state}")`        |
| to_s    | Returns state in string format                    | `logger.info(#{item.id}: #{item})`                           |

State returns nil instead of UNDEF or NULL so that it can be used with with [Ruby safe navigation operator](https://ruby-doc.org/core-2.6/doc/syntax/calling_methods_rdoc.html) `&.`  Use `undef?` or `null?` to check for those states.

To operate across an arbitrary collection of items you can place them in an [array](https://ruby-doc.org/core-2.5.0/Array.html) and execute methods against the array.

```ruby
number_items = [Livingroom_Temp, Bedroom_Temp]
logger.info("Max is #{number_items.max}")
logger.info("Min is #{number_items.min}")
```

