---
layout: default
title: Only If
nav_order: 1
has_children: false
parent: Guards
grand_parent: Usage
---

# only_if
 only_if allows rule execution when result is true and prevents when false.
 
```ruby
rule 'Set OutsideDimmer to 50% if LightSwtich turned on and OtherSwitch is also ON' do
  changed LightSwitch, to: ON
  run { OutsideDimmer << 50 }
  only_if { OtherSwitch == ON }
end
```

Because only_if uses 'truthy?' on non-block objects the above rule can also be written like this:

```ruby
rule 'Set OutsideDimmer to 50% if LightSwtich turned on and OtherSwitch is also ON' do
  changed LightSwitch, to: ON
  run { OutsideDimmer << 50 }
  only_if OtherSwitch
end
```

multiple only_if statements can be used and **all** must be true for the rule to run.

```ruby
rule 'Set OutsideDimmer to 50% if LightSwtich turned on and OtherSwitch is also ON and Door is closed' do
  changed LightSwitch, to: ON
  run { OutsideDimmer << 50 }
  only_if OtherSwitch
  only_if { Door == CLOSED }
end
```
