---
layout: default
title: Duration
nav_order: 3
has_children: false
parent: Misc
grand_parent: Usage
---

# Duration
[Ruby integers](https://ruby-doc.org/core-2.5.0/Integer.html) are extended with several methods to support durations.  These methods create a new duration object that is used by the [Every trigger](#Every), the [for option](#Changed) and [timers](#Timers). 

Extended Methods

| Method                            | Description                    |
| --------------------------------- | ------------------------------ |
| hour or hours                     | Convert number to hours        |
| minute or minutes                 | Convert number to minutes      |
| second or seconds                 | Convert number to seconds      |
| millisecond or milliseconds or ms | Convert number to milliseconds |

