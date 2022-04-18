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
to help you define relationships between items. 


## Item helper methods

Several [semantics helper methods](https://www.rubydoc.info/gems/openhab-scripting/OpenHAB/DSL/Semantics)
are defined on items in order to easily navigate this model in your scripts.
This can be extremely useful to find related items in rules that are executed for any member of a group.

## Enumerable helper methods

[Enumerable helper methods](https://www.rubydoc.info/gems/openhab-scripting/Enumerable) 
are also provided to complement the semantic model. These methods can be chained together to find specific item(s)
based on custom tags or group memberships that are outside the semantic model.

The Enumerable helper methods apply to everything from group members and `all_members`, 
Semantic [#location](https://www.rubydoc.info/gems/openhab-scripting/OpenHAB/DSL/Semantics#location-instance_method) 
and [#equipment](https://www.rubydoc.info/gems/openhab-scripting/OpenHAB/DSL/Semantics#equipment-instance_method) 
(which are just Groups), to any array of items, which includes the return value of the `#points` method.

## Examples

### Find the switch item for a scene channel on a zwave dimmer

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

### Turn off all the lights in a room

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

### Finding a related item that doesn't fit in the semantic model

We can use custom tags to identify certain items that don't quite fit in the semantic model. 
The extensions to the Enumerable mentioned above can help in this scenario.

In the following example, the TV `Equipment` has three `Points`. However, we are using custom tags
`Application` and `Channel` to identify the corresponding points, since the semantic model
doesn't have a specific property for them.

Here, we use [Enumerable#tagged](https://www.rubydoc.info/gems/openhab-scripting/Enumerable#tagged-instance_method) 
to find the point with the custom tag that we want.

```
Group   gTVPower
Group   lLivingRoom                                            ["LivingRoom"]

Group   eLivingRoom_TV             (lLivingRoom)               ["Television"]
Switch  LivingRoom_TV_Power        (eLivingRoom_TV, gTVPower)  ["Switch", "Power"]
String  LivingRoom_TV_Application  (eLivingRoom_TV)            ["Control", "Application"]
String  LivingRoom_TV_Channel      (eLivingRoom_TV)            ["Control", "Channel"]
```

```ruby
rule 'Switch TV to Netflix on startup' do
  changed gTVPower.members, to: ON
  run do |event|
    application = event.item.points.tagged('Application').first
    application << 'netflix'
  end
end
```
