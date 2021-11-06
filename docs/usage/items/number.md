---
layout: default
title: NumberItem
nav_order: 4
has_children: false
parent: Items
grand_parent: Usage
---


# NumberItem

| Method          | Parameters | Description                                                                                                                                                  | Example                                                                      |
| --------------- | ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------- |
| truthy?         |            | Item state not UNDEF, not NULL and is not Zero                                                                                                               | `puts "#{item.name} is truthy" if item.truthy?`                              |
| +,-,\*,/        | amount     | Perform the operation between the state of the number item and the supplied value*                                                                           | `NumberItem << NumberItem - 5` or `NumberItem << 10 + NumberItem`            |
| \|              | unit       | Convert the supplied NumberItem to the supplied unit. Unit can either be a Unit class or string representation of the symbol, returns a QuantityType object. | `NumberItem` &#124; `ImperialUnits::FAHRENHEIT` or `NumberItem `&#124;`'°F'` |
| to_d            |            | Returns the state as a BigDecimal or nil if state is UNDEF or NULL                                                                                           | `NumberOne.to_d`                                                             |
| to_i            |            | Returns the state as an Integer or nil if state is UNDEF or NULL                                                                                             | `NumberOne.to_i`                                                             |
| to_f            |            | Returns the state as a Float or nil if state is UNDEF or NULL                                                                                                | `NumberOne.to_f`                                                             |
| dimension       |            | Returns the dimension of the Number Item, nil if the number is dimensionless                                                                                 | `Numberone.dimension`                                                        |
| Numeric Methods |            | All methods for [Ruby Numeric](https://ruby-doc.org/core-2.6.8/Numeric.html)                                                                                 |                                                                              |

 Math operations for dimensionless numbers return a type of [Ruby BigDecimal](https://ruby-doc.org/stdlib-2.6.8/libdoc/bigdecimal/rdoc/BigDecimal.html).  Check [Quantities section](#quantities) for details of how math operations impact dimensioned numbers. 


## Examples

Math operations can be performed directly on the NumberItem

```ruby
# Add 5 to a number item
NumberOne << NumberOne + 5

# Add Number item to 5
NumberOne << 5 + NumberOne

```

Number Items can be selected in an enumerable with grep.

```ruby
# Get all NumberItems
items.grep(NumberItem)
     .each { |number| logger.info("#{number.id} is a Number Item") }
```

Number Item work with ranges and can be used in grep.

```ruby
# Get numbers in group Numbers with a state of less than 50
# Get all NumberItems less than 50
Numbers.grep(0...50)
       .each { |number| logger.info("#{number.id} is less than 50") }
```

Number Items can also be used in case statements with ranges.

```ruby
#Check if number items is less than 50
case NumberOne
when (0...50)
  logger.info("#{NumberOne.id} is less than 50")
when (50..100)
  logger.info("#{NumberOne.id} is greater than 50")
end
```

Number Items can be compared directly against Numeric

```ruby
if NumberOne > 10
  logger.info("Item #{NumberOne.name} is greater than 10")
end
```

Number Items can be compared against the value of another Number Item

```ruby
if NumberOne > NumberTwo
  logger.info("Item #{NumberOne.name} (#{NumberOne}) is greater than #{NumberTwo.name} (#{NumberTwo})")
end
```



## Quantities 
Quantities are part of the [Units of Measurement](https://www.openhab.org/docs/concepts/units-of-measurement.html)
framework in OpenHAB.  The quantity object acts as a Ruby wrapper around the
OpenHAB QuantityType. You can also construct quantities by using the pipe operator with any numeric.


| Method             | Parameters | Description                                                                                                                    | Example                                                                      |
| ------------------ | ---------- | ------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------- |
| +,-,\*,/,-(negate) | amount     | Perform the operation between the state of the number item and the supplied value*                                             | `NumberItem << NumberItem - 5` or `NumberItem << 10 + NumberItem`            |
| \|                 | unit       | Convert the supplied QuantityType to the supplied unit. Unit can either be a Unit class or string representation of the symbol | `NumberItem` &#124; `ImperialUnits::FAHRENHEIT` or `NumberItem `&#124;`'°F'` |

### Examples

QuantityTypes can perform math operations between them.

```ruby
(50 | '°F') + -(25 | '°F') # => 25.0 °F
(100 | '°F') / (2 | '°F') # => 50
(50 | '°F') - (25 | '°F') # => 25 °F
(50 | '°F') + (50 | '°F') # => 100 °F
```

If the operand is a string it will be automatically converted into a QuantityType.
```ruby
(100 | '°F') / '2 °F' # => 50
(50 | '°F') - '25 °F' # => 25 °F
(50 | '°F') + '50 °F' # => 100 °F
```

If the operand is a number, it will be unit-less, but the result of the operation will have a unit.  This only works for multiplication and division.
```ruby
(50 | '°F') * 2 # => 100 °F
(100 | '°F') / 2 # => 50 °F
```

If the operand is a dimensioned NumberItem it will automatically be converted to a quantity for the operation.
```ruby
# NumberF = '2 °F'
# NumberC = '2 °C'

(50 | '°F') + NumberF # => 52.0 °F
(50 | '°F') + NumberC # => 85.60 °F
```

If the operand is a non-dimensioned NumberItem it can be used only in multiplication and division operations.

```ruby
# Number Dimensionless = 2

(50 | '°F') * Dimensionless # => 100 °F
(50 | '°F') / Dimensionless # => 25 °F
```

Quantities can be compared, if they have comparable units.
```ruby
(50 | '°F') >  (25 | '°F')
(50 | '°F') >  (525 | '°F')
(50 | '°F') >= (50 | '°F')
(50 | '°F') == (50 | '°F')
(50 | '°F') <  (25 | '°C')
```

If the compare-to is a string, it will be automatically converted into a quantity.
```ruby
(50 | '°F') == '50 °F'
(50 | '°F') <  '25 °C'
```

Dimensioned Number Items can be converted to quantities with other units using the \| operator

```ruby
# NumberC = '23 °C'

# Using a unit 
logger.info("In Fahrenheit #{NumberC | ImperialUnits::FAHRENHEIT }")

# Using a string
logger.info("In Fahrenheit #{NumberC | '°F'}")

```

Dimensionless Number Items can be converted to quantities with units using the \| operator

```ruby
# Dimensionless = 70

# Using a unit 
logger.info("In Fahrenheit #{Dimensionless| ImperialUnits::FAHRENHEIT }")

# Using a string
logger.info("In Fahrenheit #{Dimensionless | '°F'}")

```

Dimensioned Number Items automatically use their units and convert automatically for math operations

```ruby
# Number:Temperature NumberC = 23 °C
# Number:Temperature NumberF = 70 °F

NumberC - NumberF # => 1.88 °C
NumberF + NumberC # => 143.40 °F 
```

Dimensionless Number Items can be used for multiplication and division. 

```ruby
# Number Dimensionless = 2
# Number:Temperature NumberF = 70 °F

NumberF * Dimensionless # => 140.0 °F 
NumberF / Dimensionless # => 35.0 °F
Dimensionless * NumberF # => 140.0 °F 
2 * NumberF             # => 140.0 °F 
```

Comparisons work on dimensioned number items with different, but comparable units.
```ruby
# Number:Temperature NumberC = 23 °C
# Number:Temperature NumberF = 70 °F

NumberC > NumberF # => true
```

Comparisons work with dimensioned numbers and strings representing quantities
```ruby
# Number:Temperature NumberC = 23 °C
# Number:Temperature NumberF = 70 °F

NumberC > '4 °F'   # => true
NumberC == '23 °C' # => true
```

For certain unit types, such as temperature, all unit needs to be normalized to the comparator for all operations when combining comparison operators with dimensioned numbers.

```ruby
(NumberC | '°F') - (NumberF | '°F') < '4 °F' 
```

To facilitate conversion of multiple dimensioned and dimensionless numbers the unit block may be used.  The unit block attempts to do the _right thing_ based on the mix of dimensioned and dimensionless items within the block.  Specifically all dimensionless items are converted to the supplied unit, except when they are used for multiplication or division. 

```ruby
# Number:Temperature NumberC = 23 °C
# Number:Temperature NumberF = 70 °F
# Number Dimensionless = 2

unit('°F') { NumberC - NumberF < 4 }                                # => true   
unit('°F') { NumberC - '24 °C' < 4 }                                # => true   
unit('°F') { (24 | '°C') - NumberC < 4 }                            # => true
unit('°C') { NumberF - '20 °C' < 2 }                                # => true
unit('°C') { NumberF - Dimensionless }                              # => 19.11 °C
unit('°C') { NumberF - Dimensionless < 20 }                         # => true   
unit('°C') { Dimensionless + NumberC == 25 }                        # => true
unit('°C') { 2 + NumberC == 25 }                                    # => true
unit('°C') { Dimensionless * NumberC == 46 }                        # => true
unit('°C') { 2 * NumberC == 46 }                                    # => true
unit('°C') { ( (2 * (NumberF + NumberC) ) / Dimensionless ) < 45 }  # => true
unit('°C') { [NumberC, NumberF, Dimensionless].min }                # => 2       
```
