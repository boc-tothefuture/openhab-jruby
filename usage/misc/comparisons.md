---
layout: default
title: Comparisons
has_children: false
parent: Misc
grand_parent: Usage
---

# Item and State Type Comparisons

Comparisons of items implicitly compare the states. 

```ruby
# When Item1, Item2 and Item3 all have the same state:

# State comparison
Item1 == Item2                      # => true - when they both have the same state
Item1 == items['Item2']             # => true - same as above

Item1 == ON                         # => true if Item1's state is ON
ON == Item1                         # => true if Item1's state is ON

case Item1
when OFF then logger.info('Item1 is OFF')
when ON then logger.info('Item1 is ON')
end

NumberItem1 > 5                     # Item can be compared against numbers
Outside_Temp > '24 °C'              # with Units of Measurement
StringItem1 == 'single'             # or string
DateItem1 < Time.now                # or date/time
DateItem1 < '2022-01-01'            # datetime against string
```

## Item Comparisons

To compare item objects, use the `#item` method on either item:

```ruby
# When Item1, Item2 and Item3 all have the same state:

# Item comparison
Item1 == Item2.item                 # => false - different items
Item1 == items['Item2'].item        # => false - different items
Item1 == items['Item1'].item        # => true - same item
# Using eql?
Item1.eql?(Item2)                   # => false - different items
Item1.eql?(items['Item1'])          # => true - same item

# Case statement. Given Item1, Item2 and Item3 are OFF
result =  case Item1                # => 'off' 
          when OFF then 'off'       #   OFF === Item1 is true, first match
          when Item2 then 'i2'
          when Item1 then 'i1'
          end

result =  case Item1.item           # => 'i1' 
          when OFF then 'off'       #   OFF === Item1.item   => false
          when Item2 then 'i2'      #   Item2 === Item1.item => false
          when Item1 then 'i1'      #   Item1 === Item1.item => true
          end
```

### Items within Hashes, Arrays and Groups

Using `#item` is needed for `Array#include?` and `Hash#value?`, but not necessary for hash keys or `grep`:

```ruby
# Given that:
# Item1, Item2 and Item2 contain the same state
# Item1 and Item2 belong to Group12 group
# Item3 doesn't belong to Group12 group

# Arrays and Group #include? will compare against the given item's state
[Item1, Item2].include?(Item3)        # => true - array has item(s) whose state match Item3's state
[Item1, Item2].include?(Item3.state)  # => true - same as above 

# To check for the actual item, use .item
[Item1, Item2].include?(Item3.item)   # => false - now we're checking for the item object

Group12.include?(Item3)               # => true - Item3 is not in the group but its state matches
Group12.include?(Item3.item)          # => false - now we're checking for the actual item

# GOTCHA: Hash keys and grep operate on the item itself, not its state
hash = { Item1 => 'value1', Item2 => 'value2' }
hash[Item3]                           # => nil - this will look up the item
hash[Item2]                           # => 'value2' - this will look up the item
hash[Item2.item]                      # => 'value2' - we can use an explicit .item

[Item1, Item2].grep(Item3)            # => [] - grep also looks up the item, not the state
[Item1, Item2].grep(Item3.item)       # => [] - we can use an explicit .item 
[Item1, Item2].grep(Item3.state)      # => [Item1, Item2] - same state as Item3's state
```

-----
> **In summary:** To avoid ambiguity, use the item's `#item` method whenever the item's object needs to be matched.

-----


## Type Comparisons

Some OpenHAB item types can accept different command types. For example, a Dimmer item can accept a command 
with an `OnOffType`, `IncreaseDecreaseType` or a `PercentType`. However, ultimately an item only stores its 
state in its native type, e.g. a Dimmer item's native type is PercentType.

## Loose Type-Comparisons

Comparisons between two compatible types will return true when applicable, for example:

- 0 (`PercentType`) equals `OFF` and the `off?` predicate will return true
- A positive `PercentType` equals `ON` and the `on?` predicate will return true

```ruby
DimmerItem1.update(10)
sleep 1
DimmerItem1 == 10 # => true
DimmerItem1 == ON # => true
DimmerItem1.on? # => true
DimmerItem1.off? # => false
```

```ruby
rule 'command' do
  received_command DimmerItem1
  run do |event|
    if event.command.on?
      # This will be executed even when the command is a positive PercentType
      # instead of an actual ON command
      logger.info("DimmerItem1 is being turned on")
    end
  end
end

DimmerItem1 << 100 # => This will trigger the logger.info above
```

### Bypassing Loose Type-Comparisons

If at any point you want to bypass loose type conversions, use `eql?`. Just be aware that this also bypasses the implicit conversion of an Item to its state.

```ruby
DimmerItem1.update(10)
sleep 1
logger.error DimmerItem1.eql?(10) # => false. It compares the _item_ object not its state
logger.error DimmerItem1.eql?(items['DimmerItem1']) # => true. It compares the _item_ object
logger.error DimmerItem1.state.eql?(ON) # => false
logger.error DimmerItem1.state.eql?(10) # => false
logger.error DimmerItem1.state.eql?(PercentType.new(10)) # => true
```

## Strict Type-Comparisons

Sometimes it is critical to know the exact command being sent. For example, a rule may need to distinguish between `ON` vs. a `PercentType` command. In this instance, Ruby's case equality operator `===` can be used. It will only evaluate to true if the two operands have the same type.

The strict type comparison applies to Ruby's `case` statement because it is implemented using the case equality operator `===`

```ruby
rule 'command' do
  received_command DimmerItem1
  run do |event|
    case event.command
    when ON then logger.info("DimmerItem1 received an ON command")
    when OFF then logger.info("DimmerItem1 received an OFF command")
    when 0 then logger.info("DimmerItem1 received 0 percent")
    when 1..99 then logger.info("DimmerItem1 received between 1 and 99 percent")
    when 100 then logger.info("DimmerItem1 received 100 percent")
    when INCREASE then logger.info("Increase")
    when DECREASE then logger.info("Decrease")
    when REFRESH then logger.info("Refresh")
    end
  end
end

```

Regular expressions can still be used on a StringType command.

```ruby
rule 'command' do
  received_command StringItem1
  run do |event|
    case event.command
    when /abc/ then logger.info('Command contains "abc"')
    else logger.info('Received something else')
    end
  end
end

StringItem1 << '123 abc 456' # This will log 'Command contains "abc"'
```

### Comparisons Against States

Because `case` statements match against the underlying item or state's type, beware of the following case. Note that we are checking the event's **state** this time, not command.

```ruby
rule 'dimmer' do
  changed DimmerItem1
  run do |event|
    case event.state
    when ON then logger.info("This will never match")
    when OFF then logger.info("Neither will this")
    else logger.info("This will always be the case")
    end
  end
end
```

The correct way to handle this would be to use the underlying type which is PercentType or Numeric:

```ruby
rule 'dimmer' do
  changed DimmerItem1
  run do |event|
    case event.state
    when 0 then logger.info("The dimmer is off")
    when 1..100 then logger.info("The dimmer is on")
    else logger.info("The dimmer is either NULL or UNDEF")
    end
  end
end
```
