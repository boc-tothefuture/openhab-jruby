---
layout: default
title: Not If
nav_order: 2
has_children: false
parent: Guards
grand_parent: Usage
---

#### not_if

not_if allows prevents execution of rules when result is false and prevents when true

```
 rule 'Set OutsideDimmer to 50% if LightSwtich turned on and OtherSwitch is OFF' do
        changed LightSwitch, to: ON
        run { OutsideDimmer << 50 }
        not_if { OtherSwitch == ON }
      end
```

Because not_if uses 'truthy?' on non-block objects the above rule can also be written like this:

```ruby
rule 'Set OutsideDimmer to 50% if LightSwtich turned on and OtherSwitch is OFF' do
  changed LightSwitch, to: ON
  run { OutsideDimmer << 50 }
  not_if OtherSwitch
end
```

Multiple not_if statements can be used and if **any** of them are not satisfied the rule will not run. 

```ruby
rule 'Set OutsideDimmer to 50% if LightSwtich turned on and OtherSwitch is OFF and Door is not CLOSED' do
  changed LightSwitch, to: ON
  run { OutsideDimmer << 50 }
  not_if OtherSwitch
  not_if { Door == CLOSED }
end
```
