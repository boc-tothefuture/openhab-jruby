---
layout: default
title: Creating rules in the UI
nav_order: 2
has_children: false
parent: Usage
---

## Creating rules in Main UI ##

Rules can be created in the UI as well as in rules files, but some things are a bit different.
First of all only the execution blocks need to be created in the script. All triggers and conditions
are created directly in the UI instead.

To create a rule:
1. Go to the Rules section in the UI and add a new rule.
2. Input a name for your rule, and configure the Triggers (note that only the predefined triggers are available,
the specializations the script library adds, such as the `every` trigger cannot be used)
3. When adding an Action, select **Run script**, and then **Ruby**. A script editor will open where you can write your code.
4. When you are done, save the script and go back to complete the configuration

To make all the extras available to your rule, the first line should be `require 'openhab'`. This will enable
all the special methods for Items, Things, Actions, Logging etc. that are documented here, and the event properties
documented for the Run execution block.

Note that the Delay, Triggered, and Otherwise Execution blocks cannot be used, but the same functionality can be
acheived in other ways. E.g instead of `delay 5.seconds` you can use `sleep 5` which causes the script to pause
for 5 seconds, or you can use timers like in the example below. Otherwise can be implemented with an `if-else` block. Guards can't be used either, but similar functionality can be achieved through Conditions.

## Examples ##

Reset the switch that triggered the rule after 5 seconds

Trigger defined as:
- When: a member of an item group recieves a command
- Group: Reset_5Seconds
- Command: ON

```ruby
require 'openhab'

logger.info("#{event.item.id} Triggered the rule")
after 5.seconds do
  event.item << OFF
end
```

Update a DateTime Item with the current time when a motion sensor is triggered

Trigger defined as:
- When: the state of a member of an item group is updated
- Group: MotionSensors
- State: ON

```ruby
require 'openhab'

logger.info("#{event.item.id} Triggered")
items["#{event.item_name}_LastMotion"].update Time.now
```
