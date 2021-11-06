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
|--------------------|--------------------------------------------------------------------------------|
| []                 | Get a specific item by name, this syntax can be used to dynamically load items |
| include?           | Check to see if an item with the given name exists                             |
| enumerable methods | All methods [here](https://ruby-doc.org/core-2.6.8/Enumerable.html)            |

## Examples

Item Definition
```
Dimmer DimmerTest "Test Dimmer"
Switch SwitchTest "Test Switch"

```

```ruby
logger.info("Item Count: #{items.count}")  # Item Count: 2
logger.info("Items: #{items.sort_by(&:label).map(&:label).join(', ')}")  #Items: Test Dimmer, Test Switch' 
logger.info("DimmerTest exists? #{items.include? 'DimmerTest'}") # DimmerTest exists? true
logger.info("StringTest exists? #{items.include? 'StringTest'}") # StringTest exists? false
```

```ruby
rule 'Use dynamic item lookup to increase related dimmer brightness when switch is turned on' do
  changed SwitchTest, to: ON
  triggered { |item| items[item.name.gsub('Switch','Dimmer')].brighten(10) }
end
```

```ruby
rule 'search for a suitable item' do
  on_start
  triggered do
    (items['DimmerTest'] || items['SwitchTest'])&.on # Send ON to DimmerTest if it exists, otherwise send it to SwitchTest
  end
end
```

## All Items
Item types have methods added to them to make it flow naturally within the a ruby context.  All methods of the OpenHAB item are available plus the additional methods described below.


| Method  | Description                                                                                        | Example                                                      |
|---------|----------------------------------------------------------------------------------------------------|--------------------------------------------------------------|
| <<      | Sends command to item                                                                              | `VirtualSwitch << ON`                                        |
| command | alias for shovel operator (<<) - has optional arguments 'for:, on_expire:' see timed command below | `VirtualSwitch.command(ON)`                                  |
| ensure  | Only send following command/update if the item is not already in the requested state               | `VirtualSwitch.ensure.on`                                    |
| update  | Sends update to an item                                                                            | `VirtualSwitch.update(ON)`                                   |
| id      | Returns label or item name if no label                                                             | `logger.info(#{item.id})`                                    |
| undef?  | Returns true if the state of the item is UNDEF                                                     | `logger.info("SwitchTest is UNDEF") if SwitchTest.undef?`    |
| null?   | Returns true if the state of the item is NULL                                                      | `logger.info("SwitchTest is NULL") if SwitchTest.null?`      |
| state?  | Returns true if the state is not UNDEF or NULL                                                     | `logger.info("SwitchTest has a state") if SwitchTest.state?` |
| state   | Returns state of the item or nil if UNDEF or NULL                                                  | `logger.info("SwitchTest state #{SwitchTest.state}")`        |
| to_s    | Returns state in string format                                                                     | `logger.info(#{item.id}: #{item})`                           |

State returns nil instead of UNDEF or NULL so that it can be used with with [Ruby safe navigation operator](https://ruby-doc.org/core-2.6/doc/syntax/calling_methods_rdoc.html) `&.`  Use `undef?` or `null?` to check for those states.

To operate across an arbitrary collection of items you can place them in an [array](https://ruby-doc.org/core-2.6.8/Array.html) and execute methods against the array.

```ruby
number_items = [Livingroom_Temp, Bedroom_Temp]
logger.info("Max is #{number_items.max}")
logger.info("Min is #{number_items.min}")
```

### ensure_states
The ensure_states block may be used to across multiple objects and command/updates only sending commands when state is not in the requested state. This is useful for devices where it may be costly (such as zwave) to send commands/updates for no reason.

```ruby
# VirtualSwitch is in state 'ON'
ensure_states do
  VirtualSwitch << ON       # No command will be sent
  VirtualSwitch.update(ON)  # No update will be posted
  VirtualSwitch << OFF      # Off command will be sent
  VirtualSwitch.update(OFF) # No update will be posted
end
```

Wrapping an entire rule or file in an ensure_states block will not ensure the states during execution of the rules. 

This will not work
```ruby
ensure_states do
  rule 'Items in an execution block will not have ensure_states applied to them' do
    changed VirtualSwitch
    run do 
       VirtualSwitch.on
       VirtualSwitch2.on
    end
  end
end
```

This will work
```ruby
  rule 'ensure_states must be in an execution block' do
    changed VirtualSwitch
    run do 
       ensure_states do 
          VirtualSwitch.on
          VirtualSwitch2.on
       end
    end
  end
end
```

### Timed commands
All items have an implicit timer associated with them, enabling to easily set an item into a specific state for a specified duration and then at the expiration of that duration have the item automatically change to another state. These timed commands are reentrant, meaning if the same timed command is triggered while an outstanding time command exist, that timed command will be rescheduled rather than creating a distinct timed command. 

Timed commands are initiated by using the 'for:' argument with the command.  This is available on both the 'command' method and any command methods, e.g. Switch.on.

Any update to the timed command state will result in the timer be cancelled. For example, if you have a Switch on a timer and another rule sends OFF or ON to that item the timer will be automatically canceled.  Sending a different duration (for:) value for the timed command will reschedule the timed command for that new duration.


Timed command arguments

| Argument  | Description                                                  | Example                                                            |
|-----------|--------------------------------------------------------------|--------------------------------------------------------------------|
| for       | Duration for command to be active                            | `Switch.command(ON, for: 5.minutes)` or `Switch.on for: 5.minutes` |
| on_expire | Optional value to send as command to item when timer expires | `Dimmer.on for: 5.minutes, on_expire: 50`                          |
| block     | Optional block to invoke when timer expires                  | `Dimmer.on(for: 5.minutes) { |event| Dimmer.off if Light.on? }`    |

If a block is provided, the on_expire argument is ignored and the block is expected to set the item into the desired state or carry out some action.


| Attribute | Description                                     |
|-----------|-------------------------------------------------|
| item      | Item associated with timed command              |
| command   | Time command e.g. ON, OFF, etc                  |
| was       | The state of the item before the timed command  |
| duration  | The length of the timed command                 |
| on_expire | Value to set the item to when the timer expires |
| timer     | The timed command timer                         |
| expired?  | If the timer expired                            |
| canceled? | If the timer was canceled                       |














