---
layout: default
title: LocationItem
has_children: false
parent: Items
grand_parent: Usage
---


# Location Item
Represents GPS coordinates

| Method | Description             | parameter types         | Example                 |
| ------ | ----------------------- | ----------------------- | ----------------------- |
| -      | alias for distance_from | Location, Point, String | `Location2 - Location1` |


## Examples ##

Update the location Item

```ruby
Location << '30,20'   # latitude of 30, longitude of 20
Location << {lat: 30, long: 30}
Location << {lat: 30, long: 30, alt: 80}
Location << '30,20,80' # latitude of 30, longitude of 20, altitude of 80
Location << {latitude: 30, longitude: 30}
Location << {latitude: 30, longitude: 30, altitude: 80}
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
logger.info "Distance from Location 1 to Location 2: #{Location1 - {lat: 40, long: 20}}"
logger.info "Distance from Location 1 to Location 2: #{Location1 - PointType.new('40,20')}"
```
