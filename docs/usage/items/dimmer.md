---
layout: default
title: DimmerItem
nav_order: 2
has_children: false
parent: Items
grand_parent: Usage
---

# DimmerItem

| Method   | Parameters                             | Description                                    | Example                                         |
| -------- | -------------------------------------- | ---------------------------------------------- | ----------------------------------------------- |
| truthy?  |                                        | Item state not UNDEF, not NULL and is ON       | `puts "#{item.name} is truthy" if item.truthy?` |
| on       |                                        | Send command to turn item ON                   | `item.on`                                       |
| off      |                                        | Send command to turn item OFF                  | `item.off`                                      |
| on?      |                                        | Returns true if item state == ON               | `puts "#{item.name} is on." if item.on?`        |
| off?     |                                        | Returns true if item state == OFF              | `puts "#{item.name} is off." if item.off?`      |
| dim      | amount (default 1)                     | Dim the dimmer the specified amount            | `DimmerSwitch.dim`                              |
| decrease |                                        | Decrease brightness of the dimmer              | `DimmerSwitch.decrease`                         |
| -        | amount                                 | Subtract the supplied amount from DimmerItem   | `DimmerSwitch << DimmerSwitch - 5`              |
| brighten | amount (default 1)                     | Brighten the dimmer the specified amount       | `DimmerSwitch.brighten`                         |
| increase |                                        | Increase brightness of the dimmer              | `DimmerSwitch.increase`                         |
| +        | amount                                 | Add the supplied amount from the DimmerItem    | `DimmerSwitch << DimmerSwitch + 5`              |
| <=>      | DimmerItem, NumberItem, Number, String | Compare the value of DimmerItem against others | `DimmerSwitch > 100`                            |


## Examples

```ruby
DimmerOne << DimmerOne - 5
DimmerOne << 100 - DimmerOne

```

`on`/`off` sends commands to a Dimmer

```ruby
# Turn on all dimmers in group
Dimmers.each(&:on)

# Turn off all dimmers in group
Dimmers.each(&:off)
```

 `on?`/`off?` Checks state of dimmer

```ruby
# Turn on switches that are off
Dimmers.select(&:off?).each(&:on)

# Turn off switches that are on
Dimmers.select(&:on?).each(&:off)
```

`dim` dims the specified amount, defaulting to 1. If 1 is the amount, the decrease command is sent, otherwise the current state - amount is sent as a command.

```ruby
DimmerOne.dim
DimmerOne.dim 2
```

`brighten` brightens the specified amount, defaulting to 1. If 1 is the amount, the increase command is sent, otherwise the current state + amount is sent as a command.

```ruby
DimmerOne.brighten
DimmerOne.brighten 2   
```

Dimmers can be selected in an enumerable with grep.

```ruby
# Get all dimmers
items.grep(DimmerItem)
     .each { |dimmer| logger.info("#{dimmer.id} is a Dimmer") }
```

Dimmers work with ranges and can be used in grep.

```ruby
# Get dimmers with a state of less than 50
items.grep(DimmerItem)
     .grep(0...50)
     .each { |item| logger.info("#{item.id} is less than 50") }
```

Dimmers can also be used in case statements with ranges.
```ruby
#Log dimmer states partioning aat 50%
items.grep(DimmerItem)
     .each do |dimmer|
       case dimmer
       when (0..50)
         logger.info("#{dimmer.id} is less than 50%")
        when (51..100)
         logger.info("#{dimmer.id} is greater than 50%")
         end
end
```

Other examples

```ruby
rule 'Dim a switch on system startup over 100 seconds' do
  on_start
  100.times do
    run { DimmerSwitch.dim }
    delay 1.second
  end
end

```

```ruby
rule 'Dim a switch on system startup by 5, pausing every second' do
   on_start
   100.step(-5, 0) do | level |
     run { DimmerSwitch << level }
     delay 1.second
   end
end
```

```ruby
rule 'Turn off any dimmers curently on at midnight' do
   every :day
   run do
     items.grep(DimmerItem)
          .select(&:on?)
          .each(&:off)
    end
end
```

```ruby
rule 'Turn off any dimmers set to less than 50 at midnight' do
   every :day
   run do
     items.grep(DimmerItem)
          .grep(1...50)
          .each(&:off)
     end
end
```
