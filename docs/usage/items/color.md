---
layout: default
title: ColorItem
nav_order: 1
has_children: false
parent: Items
grand_parent: Usage
---


# ColorItem

ColorItem represents a color. Note that it inherits from DimmerItem, so you can
call `on`, `off`, `on?`, `off?`, etc. on it. It's state type is an `HSBType`, which
is generally stored as Hue, Saturation, and Brightness, but has easy helpers for
working with RGB values of various forms.

| Method     | Description                                                                     |
| ---------- | ------------------------------------------------------------------------------- |
| hue        | Returns the color's hue component as a QuantityType of unit DEGREE_ANGLE        |
| saturation | Returns the color's saturation component as a PercentType                       |
| brightness | Returns the color's brightness component as a PercentType                       |
| red        | Returns the color's red component as a PercentType                              |
| green      | Returns the color's green component as a PercentType                            |
| blue       | Returns the color's blue component as a PercentType                             |
| to_rgb     | Returns an array of length 3 PercentType, corresponding to red, blue, and green |
| argb       | Returns a 32-bit integer of 2-bytes per alpha/red/blue/green component          |
| rgb        | Returns a 32-bit integer of 2-bytes per red/blue/green component                |
| to_hex     | Returns a string of the RGB color value in HTML format (#ffffff)                |

## Examples

```ruby
HueBulb << "#ff0000" # send 'red' as a command
HueBulb.red # => 100%
HueBulb.hue # => 0 °
HueBulb.brightness # => 100%
HueBulb.to_rgb # => [100%, 0%, 0%]
HueBulb.rgb # => 16711680
HueBulb.to_hex # => "0xff0000"
HueBulb.on? # => true
HueBulb.red.to_byte # => 255
HubBulb.blue.to_byte # => 0

HueBulb.on
HueBulb.dim
```
