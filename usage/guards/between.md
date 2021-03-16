---
layout: default
title: Between
nav_order: 3
has_children: false
parent: Guards
grand_parent: Usage
---

# between
Only runs the rule if the current time is in the provided range

```ruby
rule 'Log an entry if started between 3:30:04 and midnight using strings' do
  on_start
  run { logger.info ("Started at #{TimeOfDay.now}")}
  between '3:30:04'..MIDNIGHT
end
```

or

```ruby
rule 'Log an entry if started between 3:30:04 and midnight using TimeOfDay objects' do
  on_start
  run { logger.info ("Started at #{TimeOfDay.now}")}
  between TimeOfDay.new(h: 3, m: 30, s: 4)..MIDNIGHT
end
```

