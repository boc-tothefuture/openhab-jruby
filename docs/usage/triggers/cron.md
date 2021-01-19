---
layout: default
title: Cron
nav_order: 2
has_children: false
parent: Triggers
grand_parent: Usage
---


# Cron
Utilizes [OpenHAB style cron expressions](https://www.openhab.org/docs/configuration/rules-dsl.html#time-based-triggers) to trigger rules.  This property can be utilized when you need to represent complex expressions not possible with the simpler [every](#Every) syntax.

```ruby
rule 'Using Cron Syntax' do
  cron '43 46 13 ? * ?'
  run { logger.info "Cron rule executed" }
end
```
