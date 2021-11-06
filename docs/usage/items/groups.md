---
layout: default
title: Groups
nav_order: 5
has_children: false
parent: Items
grand_parent: Usage
---

# Groups

A group can be accessed directly by name, to access all groups use the `groups` method. A Group behaves like a regular Item, but also lets you iterate through it's members and use all the available methods of 
[Enumerable](https://ruby-doc.org/core-2.6.8/Enumerable.html). If the group have a type all methods of that type is directly available.


## Group Methods

| Method             | Description                                                                                     |
| ------------------ | ----------------------------------------------------------------------------------------------- |
| members            | Used to inform a rule that you want it to operate on the items in the group (see example below) |
| all_members        | Gets all descendants of the group recursively excluding groups. Pass :all as argument to include groups as well, or :groups to only get the sub groups. It's also possible to pass a block to make more advanced filters |
| each               | Iterates through the members of the group and execute the code in the provided block for each member |
| enumerable methods | All methods [here](https://ruby-doc.org/core-2.6.8/Enumerable.html)                             |

## Use in triggers

Groups can be used in triggers in two different ways:

```ruby
changed Switches # Executes the rule when the state of the group item changes
```
or

```ruby
changed Switches.members # Executes the rule when any of the groups members changes its state
```


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
logger.info("Temperatures: #{House.all_members.sort_by(&:label).map(&:label).join(', ')}") #Temperatures: Bedroom temperature, Den temperature, Living Room temperature' 

#Access to the methods and attributes like any item
logger.info("Group: #{Temperatures.name}" # Group: Temperatures'

#Operates on items in nested groups using enumerable methods
logger.info("House Count: #{House.all_members.count}")           # House Count: 3
logger.info("Items: #{House.all_members.sort_by(&:label).map(&:label).join(', ')}")  # Items: Bedroom temperature, Den temperature, Living Room temperature

#Access to sub groups using all_members(:groups)
logger.info("House Sub Groups: #{House.all_members(:groups).count}")  # House Sub Groups: 4
logger.info("Groups: #{House.all_members(:groups).sort_by(&:id).map(&:id).join(', ')}")  # Groups: GroundFloor, Livingroom, Sensors, Temperatures

#Filter the items returned by `all_members` in other ways using a block
logger.info(House.all_members { |item| /.*room.*/.match?(item.name) }.sort_by(&:name).map(&:name).join(', ')) # Bedroom_Temp, Livingroom, Livingroom_Temperature

#Iterate through the direct members of the group
Temperatures.each do |item|
  logger.info("#{item.id} is: #{item}")
end
#Logs:
#Living Room temperature is 22
#Bedroom temperature is 21
#Den temperature is 19

```


```ruby
rule 'Turn off any switch that changes' do
  changed Switches.members
  triggered &:off
end
```

Built in [enumerable](https://ruby-doc.org/core-2.6.8/Enumerable.html)/[set](https://ruby-doc.org/stdlib-2.6.8/libdoc/set/rdoc/Set.html) functions can be applied to groups.  
```ruby
logger.info("Max is #{Temperatures.max}")
logger.info("Min is #{Temperatures.min}")
```
