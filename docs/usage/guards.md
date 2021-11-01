---
layout: default
title: Guards
nav_order: 3
has_children: true
parent: Usage
---

# Guards

Guards exist to only permit rules to run if certain conditions are satisfied. Think of these as declarative if statements that keep the run block free of conditional logic, although you can of course still use conditional logic in run blocks if you prefer. 

only_if and not_if guards that are provided items or arrays of items rather than blocks automatically check for the 'truthyness' of the supplied object.  Any item that is defined and not NULL is truthy.  Certain other types have additional restrictions on truthyness to make them easier to use in rules.

Truthyness for Item types:

| Item       | Truthy when        |
|------------|--------------------|
| Switch     | state == ON        |
| Dimmer     | state != 0         |
| String     | Not Blank          |



## Guard Combination

only_if and not_if can be used on the same rule, both be satisfied for a rule to execute.

```ruby
rule 'Set OutsideDimmer to 50% if LightSwtich turned on and OtherSwitch is OFF and Door is CLOSED' do
  changed LightSwitch, to: ON
  run { OutsideDimmer << 50 }
  only_if { Door == CLOSED }
  not_if OtherSwitch
end
```


#### Guard Event Access
Guards have access to event information.

```ruby
rule 'Set OutsideDimmer to 50% if any switch in group Switches starting with Outside is switched On' do
  changed Switches.items, to: ON
  run { OutsideDimmer << 50 }
  only_if { |event| event.item.name.start_with? 'Outside' }
end
```

