---
layout: default
title: PlayerItem
nav_order: 1
has_children: false
parent: Items
grand_parent: Usage
---


# PlayerItem

Player Items allow control of elements like audio players, televisions, etc. All methods of the underlying OpenHAB Player Item exist along with Ruby like method / extensions

| Method           | Description                               | Example                                                           |
| ---------------- | ----------------------------------------- | ----------------------------------------------------------------- |
| play             | Send PLAY command to item                 | `item.play`                                                       |
| pause            | Send PAUSE command to item                | `item.pause`                                                      |
| rewind           | Send REWIND command to item               | `item.rewind`                                                     |
| fast_forward     | Send FASTFORWARD command to item          | `item.fast_forward`                                               |
| next             | Send NEXT command to item                 | `item.next`                                                       |
| previous         | Send PREVIOUS command to item             | `item.previous`                                                   |
| playing?         | Returns true if item state == PLAY        | `puts "#{item.name} is playing" if item.playing?`                 |
| paused?          | Returns true if item state == PAUSED      | `puts "#{item.name} is paused" if item.paused?`                   |
| rewinding?       | Returns true if item state == REWIND      | `puts "#{item.name} is rewinding" if item.rewinding?`             |
| fast_forwarding? | Returns true if item state == FASTFORWARD | `puts "#{item.name} is fast forwarding" if item.fast_forwarding?` |


## Examples ##

Start play on a player item

```ruby
Chromecast.play
```

Check if a player is paused

```ruby
logger.warn("#{item.id} is paused) if Chromecast.paused?
```
