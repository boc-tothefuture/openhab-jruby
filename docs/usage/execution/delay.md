---
layout: default
title: Delay
nav_order: 3
has_children: false
parent: Execution Blocks
grand_parent: Usage
---


# Delay
The delay property is a non thread-blocking element that is executed after, before, or between run blocks. 

```ruby
rule 'Delay sleeps between execution elements' do
  on_start
  run { logger.info("Sleeping") }
  delay 5.seconds
  run { logger.info("Awake") }
end
```

Like other execution blocks, multiple can exist in a single rule.

```ruby
rule 'Multiple delays can exist in a rule' do
  on_start
  run { logger.info("Sleeping") }
  delay 5.seconds
  run { logger.info("Sleeping Again") }
  delay 5.seconds
  run { logger.info("Awake") }
end
```


You can use ruby code in your rule across multiple execution blocks like a run and a delay. 
```ruby
rule 'Dim a switch on system startup over 100 seconds' do
   on_start
   100.times do
     run { DimmerSwitch.dim }
     delay 1.second
   end
 end

```

