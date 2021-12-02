---
layout: default
title: Semantics
nav_order: 2
has_children: false
parent: Misc
grand_parent: Usage
---

# Semantics

OpenHAB supports a [semantic model](https://www.openhab.org/docs/tutorial/model.html)
to help you define relationships between items. Several
[helper methods](https://www.rubydoc.info/gems/openhab-scripting/OpenHAB/DSL/Items/Semantics)
are defined on items in order to easily navigate this model in your scripts.
This can be extremely useful to find related items in rules that are executed
for any member of a group. Here are a few examples:

## Find the switch item for a scene channel on a zwave dimmer

switches.items
```
Group gFullOn

Group eGarageLights "Garage Lights" (lGarage) [ "Lightbulb" ]
Dimmer GarageLights_Dimmer "Garage Lights" <light> (eGarageLights) [ "Switch" ]
Number GarageLights_Scene "Scene" (eGarageLights, gFullOn)

Group eMudLights "Mud Room Lights" (lMud) [ "Lightbulb" ]
Dimmer MudLights_Dimmer "Garage Lights" <light> (eMudLights) [ "Switch" ]
Number MudLights_Scene "Scene" (eMudLights, gFullOn)
```

switches.rb
```ruby
rule "turn dimmer to full on when switch double-tapped up" do
  changed gFullOn.members, to: 1.3
  run do |event|
    dimmer_item = event.item.points(Semantics::Switch).first
    dimmer_item.ensure << 100
  end
end
```

## Turn off all the lights in a room

```
Group gRoomOff

Group eGarageLights "Garage Lights" (lGarage) [ "Lightbulb" ]
Dimmer GarageLights_Dimmer "Garage Lights" <light> (eGarageLights) [ "Switch" ]
Number GarageLights_Scene "Scene" (eGarageLights, gRoomOff)

Group eMudLights "Mud Room Lights" (lGarage) [ "Lightbulb" ]
Dimmer MudLights_Dimmer "Garage Lights" <light> (eMudLights) [ "Switch" ]
Number MudLights_Scene "Scene" (eMudLights)
```

switches.rb
```ruby
rule "turn off all lights in the room when switch double-tapped down" do
  changed gRoomOff.members, to: 2.3
  run do |event|
    event
      .item
      .location
      .equipments(Semantics::Lightbulb)
      .flat_map(&:members)
      .points(Semantics::Switch)
      .ensure.off
  end
end
```
