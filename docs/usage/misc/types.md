---
layout: default
title: Types
nav_order: 4
has_children: false
parent: Misc
grand_parent: Usage
---

# Types
Types are the specific data types that commands and states are. They can be 
sent to items, be the current state of an item, or be the `command`, `state`,
and `was` field of various [triggers](execution/run). Some types have
additional useful methods.

## OnOffType

`OnOffType` is the data type used by `SwitchItem`.

| Method | Description  |
| ------ | ------------ |
| on?    | If it's ON   |
| off?   | If it's OFF  |

## UpDownType

| Method | Description  |
| ------ | ------------ |
| up?    | If it's UP   |
| down?  | If it's DOWN |

## PercentType

`PercentType` is the data type used by `DimmerItem` and `RollershutterItem`

| Method       | Description                                                                        |
| ------------ | ---------------------------------------------------------------------------------- |
| up?          | The value is first coerced to UpDownType, then if it's UP                          |
| down?        | The value is first coerced to UpDownType, then if it's DOWN                        |
| on?          | The value is first coerced to OnOffType, then if it's ON                           |
| off?         | The value is first coerced to OnOffType, then if it's OFF                          |
| scale(range) | Scale the value to the given range. I.e. PercentType.new(50).scale(-50..10) => -20 |
| to_byte      | Scale the value to a byte (i.e. 0-255)                                             |
