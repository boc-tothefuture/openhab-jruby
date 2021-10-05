---
layout: default
title: Examples
nav_order: 5
has_children: true
---

## Examples

### Log "Rule *name* executed" an entry every minute

```ruby
rule 'Simple' do |rule|
  every :minute
  run { logger.info "Rule #{rule.name} executed" }
end

```

### The rule definition itself is just ruby code

Meaning you can use code itself to generate your rules*

```ruby
rule 'Log whenever a Virtual Switch Changes' do
  items.select { |item| item.is_a? Switch }
       .select { |item| item.label&.include? 'Virtual' }
       .each do |item|
         changed item
       end

  run { |event| logger.info "#{event.item.id} changed from #{event.was} to #{event.state}" }
end
```

Which is the same as
```ruby
virtual_switches = items.select { |item| item.is_a? Switch }
                        .select { |item| item.label&.include? 'Virtual' }

rule 'Log whenever a Virtual Switch Changes 2' do
  changed virtual_switches
  run { |event| logger.info "#{event.item.id} changed from #{event.was} to #{event.state} 2" }
end
```

This will accomplish the same thing, but create a new rule for each virtual switch*
```ruby
virtual_switches = items.select { |item| item.is_a? Switch }
                        .select { |item| item.label&.include? 'Virtual' }

virtual_switches.each do |switch|
  rule "Log whenever a #{switch.label} Changes" do
    changed switch
    run { |event| logger.info "#{event.item.id} changed from #{event.was} to #{event.state} 2" }
  end
end
```

* Take care when doing this as the the items/groups are processed when the rules file is processed, meaning that new items/groups will not automatically generate new rules. 

