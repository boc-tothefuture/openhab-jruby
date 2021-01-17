---
layout: default
title: Groups
nav_order: 5
has_children: false
parent: Items
grand_parent: Usage
---

# Groups

A group can be accessed directly by name, to access all groups use the `groups` method. 


## Group Methods

| Method             | Description                                                                                     |
| ------------------ | ----------------------------------------------------------------------------------------------- |
| group              | Access Group Item                                                                               |
| items              | Used to inform a rule that you want it to operate on the items in the group (see example below) |
| groups             | Direct subgroups of this group                                                                  |
| set methods        | All methods [here](https://ruby-doc.org/stdlib-2.5.0/libdoc/set/rdoc/Set.html)                  |
| enumerable methods | All methods [here](https://ruby-doc.org/core-2.5.0/Enumerable.html)                             |


## Examples

Given the following

```
Group House
// Location perspective
Group GroundFloor  (House)
Group Livingroom   (GroundFloor)
// Functional perspective
Group Sensors      (House)
Group Temperatures (Sensors)

Number Livingroom_Temperature "Living Room temperature" (Livingroom, Temperatures)
Number Bedroom_Temp "Bedroom temperature" (GroundFloor, Temperatures)
Number Den_Temp "Den temperature" (GroundFloor, Temperatures)
```

The following are log lines and the output after the comment

```ruby
#Operate on items in a group using enumerable methods
logger.info("Total Temperatures: #{Temperatures.count}")     #Total Temperatures: 3'
logger.info("Temperatures: #{House.sort_by(&:label).map(&:label).join(', ')}") #Temperatures: Bedroom temperature, Den temperature, Living Room temperature' 

#Access to the group object via the 'group' method
logger.info("Group: #{Temperatures.group.name}" # Group: Temperatures'

#Operates on items in nested groups using enumerable methods
logger.info("House Count: #{House.count}")           # House Count: 3
llogger.info("Items: #{House.sort_by(&:label).map(&:label).join(', ')}")  # Items: Bedroom temperature, Den temperature, Living Room temperature

#Access to sub groups using the 'groups' method
logger.info("House Sub Groups: #{House.groups.count}")  # House Sub Groups: 2
logger.info("Groups: #{House.groups.sort_by(&:id).map(&:id).join(', ')}")  # Groups: GroundFloor, Sensors

```


```ruby
rule 'Turn off any switch that changes' do
  changed Switches.items
  triggered &:off
end
```

Built in [enumerable](https://ruby-doc.org/core-2.5.1/Enumerable.html)/[set](https://ruby-doc.org/stdlib-2.5.1/libdoc/set/rdoc/Set.html) functions can be applied to groups.  
```ruby
logger.info("Max is #{Temperatures.max}")
logger.info("Min is #{Temperatures.min}")
```
