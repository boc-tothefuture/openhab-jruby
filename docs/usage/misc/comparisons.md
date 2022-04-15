---
layout: default
title: Comparisons
nav_order: 12
has_children: false
parent: Misc
grand_parent: Usage
---

# Item and State Type Comparisons

Comparison of two items implicitly compares their states. For example:

```ruby
if Item1 == Item2
  logger.info('The state of Item1 is the same as the state of Item2')
end
```

Comparing the actual items can be achieved using `#item` method of either operand:

```ruby
Item1.item == items['Item1'].item   # This would always return true
Item1.item == Item2.item            # This would always return false

# When Item1, Item2 and Item3 all have the same state:
[Item1, Item2].include?(Item3.item) # => false - Check for the existence of Item3 inside the array
[Item1, Item2].include?(Item3)      # => true - State check
```

Using `#item` is not necessary for hash keys because Hash keys are indexed by their hash codes.

```ruby
# When Item1 and Item2 contain the same state:
hash = { Item1 => 'value1', Item2 => 'value2' }
hash[Item2] # => 'value2' this will correctly match Item2's value in the hash
```

Some OpenHAB item types can accept different command types. For example, a Dimmer item can accept a command 
with an `OnOffType`, `IncreaseDecreaseType` or a `PercentType`. However, ultimately an item only stores its 
state in its native type, e.g. a Dimmer item's native type is PercentType.

## Loose Type Comparisons

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

### Bypassing Loose Type Comparisons

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

## Strict Type Comparisons

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
