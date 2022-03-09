---
layout: default
title: Cron
nav_order: 4
has_children: false
parent: Triggers
grand_parent: Usage
---

# cron

Utilizes [OpenHAB style cron expressions](https://www.openhab.org/docs/configuration/rules-dsl.html#time-based-triggers) to trigger rules.  This property can be utilized when you need to represent complex expressions not possible with the simpler [every]({{ site.baseurl }}{% link usage/triggers/every.md %}) syntax.

## Example

```ruby
rule 'Using Cron Syntax' do
  cron '43 46 13 ? * ?'
  run { logger.info "Cron rule executed" }
end
```
