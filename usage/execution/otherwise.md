---
layout: default
title: Otherwise
nav_order: 4
has_children: false
parent: Execution Blocks
grand_parent: Usage
---


# Otherwise
The otherwise property is the automation code that is executed when a rule is triggered and guards are not satisfied.  This property accepts a block of code and executes it. The block is automatically passed an event object which can be used to access multiple properties about the triggering event. 

## Event Properties

| Property | Description                      |
| -------- | -------------------------------- |
| item     | Triggering item                  |
| state    | Changed state of triggering item |
| last     | Last state of triggering item    |

```ruby
rule 'Turn switch ON or OFF based on value of another switch' do
  on_start
  run { TestSwitch << ON }
  otherwise { TestSwitch << OFF }
  only_if { OtherSwitch == ON }
end
```

