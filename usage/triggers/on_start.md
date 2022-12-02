---
layout: default
title: On Start
nav_order: 7
has_children: false
parent: Triggers
grand_parent: Usage
---

# on_start

Execute the rule on OpenHAB start up and whenever the script is reloaded.
It is useful to perform initialization routines, especially when combined with other triggers.

## Examples

```ruby
rule 'Ensure all security lights are on' do
  on_start
  run { Security_Lights << ON }
end
```
