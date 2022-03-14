---
layout: default
title: Creating Rules in the UI
nav_order: 7
has_children: false
parent: Usage
---

# Creating Rules in Main UI

Rules can be created in the UI as well as in rules files, but some things are a bit different.
First of all, only the execution blocks need to be created in the script. All triggers and conditions
are created directly in the UI instead.

**To create a rule:**

1. Go to the Rules section in the UI and add a new rule.
2. Input a name for your rule, and configure the Triggers through the UI.
3. When adding an Action, select **Run script**, and then **Ruby**. A script editor will open where you can write your code.
4. When you are done, save the script and go back to complete the configuration.

## UI Rules vs File-based Rules

The following features of this library are only usable within file-based rules:

* `Triggers`: UI-based rules provide equivalent triggers through the UI.
* `Guards`: UI-based rules use `Conditions` in the UI instead. Alternatively it can be implemented inside the rule code.
* `Execution Blocks`: The UI-based rules will execute your JRuby script as if it's inside a `run` execution block. 
A special `event` variable is available within your code to provide it with additional information regarding the event. 
For more details see the [run execution block]({{ site.baseurl }}{% link usage/execution/run.md %}).
* `delay`: There is no direct equivalent in the UI. It can be achieved using timers like in the example below.
* `otherwise`: There is no direct equivalent in the UI. However, it can be implemented within the rule using an `if-else` block.

## Loading the Scripting Library

To make all the features offered by this library available to your rule, the JRuby scripting addon needs to
be [configured]({{ site.baseurl }}{% link usage/items/index.md %}#from-the-user-interface) to install the `openhab-scripting` gem and
require the `openhab` script. This will enable all the special methods for [Items]({{ site.baseurl }}{% link usage/items/index.md %}),
[Things]({{ site.baseurl }}{% link usage/things.md %}), [Actions]({{ site.baseurl }}{% link usage/misc/actions.md %}), [Logging]({{ site.baseurl }}{% link usage/misc/logging.md %}) etc. that are documented here,
and the `event` properties documented for the [Run execution block]({{ site.baseurl }}{% link usage/execution/run.md %}).

## Examples

### Reset the switch that triggered the rule after 5 seconds

Trigger defined as:

- When: a member of an item group receives a command
- Group: Reset_5Seconds
- Command: ON

```ruby
logger.info("#{event.item.id} Triggered the rule")
after 5.seconds do
  event.item << OFF
end
```

### Update a DateTime Item with the current time when a motion sensor is triggered

Given the following group and items:
```
Group MotionSensors
Switch Sensor1 (MotionSensors)
Switch Sensor2 (MotionSensors)

DateTime Sensor1_LastMotion
DateTime Sensor2_LastMotion
```

Trigger defined as:

- When: the state of a member of an item group is updated
- Group: MotionSensors
- State: ON

```ruby
logger.info("#{event.item.id} Triggered")
items["#{event.item_name}_LastMotion"].update Time.now
```
