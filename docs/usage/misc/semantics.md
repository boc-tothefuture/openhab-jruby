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

Several [semantics helper methods](https://www.rubydoc.info/gems/openhab-scripting/OpenHAB/DSL/Items/Semantics)
are defined on items in order to easily navigate this model in your scripts.
This can be extremely useful to find related items in rules that are executed for any member of a group.

| Method           | Description                                                                                                                                                                                                                                           |
| ---------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `semantic?`      | Returns true if the item has any semantic tags                                                                                                                                                                                                        |
| `location?`      | Returns true if the item is a location                                                                                                                                                                                                                |
| `equipment?`     | Returns trus if the item is an equipment                                                                                                                                                                                                              |
| `point?`         | Returns true if the item is a point                                                                                                                                                                                                                   |
| `location`       | The location group item that this item belongs to, or nil if it has no location.                                                                                                                                                                      |
| `equipment`      | The equipment item that this item belongs to, or nil if it doesn't belong to an equipment.                                                                                                                                                            |
| `points`         | Returns the related Point items. If the item is a location or an equipment, returns all the Points within its members. Otherwise, returns its sibling Points. Accepts 1-2 optional arguments of point type and/or property type to filter the result. |
| `semantic_type`  | Returns the item's semantic class                                                                                                                                                                                                                     |
| `location_type`  | Returns the sub-class of `Location` related to this Item                                                                                                                                                                                              |
| `equipment_type` | Returns the sub-class of `Equipment` related to this Item                                                                                                                                                                                             |
| `point_type`     | Returns the sub-class of `Point` this Item is tagged with                                                                                                                                                                                             |
| `property_type`  | Returns the sub-class of `Property` this Item is tagged with                                                                                                                                                                                          |

Note: In openHAB 3.2, `Item#equipment` and `Item#location` will return itself instead of its parent equipment or location if it itself is an equipment or a location.
This behavior changed in openHAB 3.3 to return its parent equipment/location or nil if none is found.

## Enumerable helper methods

[Enumerable helper methods](https://www.rubydoc.info/gems/openhab-scripting/Enumerable)
are also provided to complement the semantic model. These methods can be chained together to find specific item(s)
based on custom tags or group memberships that are outside the semantic model.

| Method          | Description                                                                                                                                                  |
| --------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `sublocations`  | Selects elements that are a semantics Location (optionally of the given type)                                                                                |
| `equipments`    | Selects elements that are a semantics equipment (optionally of the given type)                                                                               |
| `points`        | Selects elements that are semantics points (optionally of a given type)                                                                                      |
| `tagged`        | Selects elements that have at least one of the given tags                                                                                                    |
| `not_tagged`    | Selects elements that do not have any of the given tags                                                                                                      |
| `member_of`     | Selects elements that are a member of at least one of the given groups                                                                                       |
| `not_member_of` | Selects elements that are not a member of any of the given groups                                                                                            |
| `command`       | Send a command to every item in the collection                                                                                                               |
| `update`        | Update the state of every item in the collection                                                                                                             |
| `ensure`        | Apply [ensure state]({{ site.baseurl }}{% link usage/items/index.md %}#ensure_states) check on each member when `command` or `update` is chained afterwards. |
| `members`       | Returns a new array that contains the group members of the elements. This is handy for finding Points in an array of Equipments or Locations.                |

The Enumerable helper methods apply to:

* Group item's `members` and `all_members`. This includes semantic
  [#location](https://www.rubydoc.info/gems/openhab-scripting/OpenHAB/DSL/Items/Semantics#location-instance_method)
  and [#equipment](https://www.rubydoc.info/gems/openhab-scripting/OpenHAB/DSL/Items/Semantics#equipment-instance_method)
  because they are also group items. An exception is for Equipments that are an item (not a group)
* Array of items, such as the return value of `#equipments`, `#sublocations`, `#points`, `#tagged`, `#not_tagged`,
  `#member_of`, `#not_member_of`, `#members` methods, etc.

## Semantic Classes

Each [Semantic Tag](https://github.com/openhab/openhab-core/blob/main/bundles/org.openhab.core.semantics/model/SemanticTags.csv)
has a corresponding class within the `org.openhab.core.semantics.model` class hierarchy. These `semantic classes` are available
as constants in the `Semantics` module with the corresponding name. The following table illustrates the semantic constants:

| Semantic Constant       | openHAB's Semantic Class                               |
| ----------------------- | ------------------------------------------------------ |
| `Semantics::LivingRoom` | `org.openhab.core.semantics.model.location.LivingRoom` |
| `Semantics::Lightbulb`  | `org.openhab.core.semantics.model.equipment.Lightbulb` |
| `Semantics::Control`    | `org.openhab.core.semantics.model.point.Control`       |
| `Semantics::Switch`     | `org.openhab.core.semantics.model.point.Switch`        |
| `Semantics::Power`      | `org.openhab.core.semantics.model.property.Power`      |
| ...                     | ...                                                    |

These constants can be used as arguments to the `#points`, `#sublocations` and `#equipments` methods to filter their results.
They can also be compared against the return value of `semantic_type`, `location_type`, `equipment_type`,
`point_type`, and `property_type`.

```ruby
# Return an array of sibling points with a "Switch" tag
Light_Color.points(Semantics::Switch)

# check semantic type
LoungeRoom_Light.equipment_type == Semantics::Lightbulb
Light_Color.property_type == Semantics::Light
```

## Examples

### Find the switch item for a scene channel on a zwave dimmer

switches.items

```java
Group   gFullOn

Group   eGarageLights        "Garage Lights"             (lGarage)                 [ "Lightbulb" ]
Dimmer  GarageLights_Dimmer  "Garage Lights"    <light>  (eGarageLights)           [ "Switch" ]
Number  GarageLights_Scene   "Scene"                     (eGarageLights, gFullOn)

Group   eMudLights           "Mud Room Lights"           (lMud)                    [ "Lightbulb" ]
Dimmer  MudLights_Dimmer     "Garage Lights"    <light>  (eMudLights)              [ "Switch" ]
Number  MudLights_Scene      "Scene"                     (eMudLights, gFullOn)
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

```java
Group   gRoomOff

Group   eGarageLights        "Garage Lights"             (lGarage)                  [ "Lightbulb" ]
Dimmer  GarageLights_Dimmer  "Garage Lights"    <light>  (eGarageLights)            [ "Switch" ]
Number  GarageLights_Scene   "Scene"                     (eGarageLights, gRoomOff)

Group   eMudLights           "Mud Room Lights"           (lGarage)                  [ "Lightbulb" ]
Dimmer  MudLights_Dimmer     "Garage Lights"    <light>  (eMudLights)               [ "Switch" ]
Number  MudLights_Scene      "Scene"                     (eMudLights)
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
      .members
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

```java
Group   gTVPower
Group   lLivingRoom                                 [ "LivingRoom" ]

Group   eTV             "TV"       (lLivingRoom)    [ "Television" ]
Switch  TV_Power        "Power"    (eTV, gTVPower)  [ "Switch", "Power" ]
String  TV_Application  "App"      (eTV)            [ "Control", "Application" ]
String  TV_Channel      "Channel"  (eTV)            [ "Control", "Channel" ]
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
