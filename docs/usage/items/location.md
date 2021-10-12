---
layout: default
title: Location
nav_order: 1
has_children: false
parent: Items
grand_parent: Usage
---


# Location Item
Represents GPS coordinates

| Method | Description                            | parameter types         | Example                 |
| ------ | -------------------------------------- | ----------------------- | ----------------------- |
| -      | alias for distance_from                | Location, Point, String | `Location2 - Location1` |


## Examples ##

Update the location Item

```ruby
Location << '30,20'
```

or

```ruby
Location << PointType.new('40,20') 
```


Determine the distance between two locations
```ruby
logger.info "Distance from Location 1 to Location 2: #{Location1 - Location2}"
logger.info "Distance from Location 1 to Location 2: #{Location1 - Location2.state}"
logger.info "Distance from Location 1 to Location 2: #{Location1 - '40,20'}"
logger.info "Distance from Location 1 to Location 2: #{Location1 - PointType.new('40,20')}"
```
