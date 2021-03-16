---
layout: default
title: Rule Conversions
nav_order: 1
has_children: false
parent: Examples
---


## Conversion Examples

DSL

```ruby
rule 'Snap Fan to preset percentages'
when Member of CeilingFans changed
then
  val fan = triggeringItem
  val name = String.join(" ", fan.name.replace("LoadLevelStatus","").split("(?<!^)(?=[A-Z])"))
  logInfo("Fan", "Ceiling fan group rule triggered for {}, value {}", name,fan.state)
  switch fan {
  	case fan.state >0 && fan.state < 25 : {
  		logInfo("Fan", "Snapping {} to 25%", name)
  		sendCommand(fan, 25)
  	}
  	case fan.state > 25 && fan.state < 66 : {
  		logInfo("Fan", "Snapping {} to 66%", name)
  		sendCommand(fan, 66)
  	}
  	case fan.state > 66 && fan.state < 100 : {
  		logInfo("Fan", "Snapping {} to 100%", name)
  		sendCommand(fan, 100)
  	}
	default: {
  		logInfo("Fan", "{} set to snapped percentage, no action taken", name)
	}
  }
end
```

Ruby
```ruby
rule 'Snap Fan to preset percentages' do
  changed CeilingFans.members
  triggered do |item|
    snapped = case item
              when 0...25 then 25
              when 26...66 then 66
              when 67...100 then 100
              end
    if snapped
      logger.info("Snapping fan #{item.id} to #{snapped}")
      item << snapped
    else
      logger.info("#{item.id} set to snapped percentage, no action taken.")
    end
  end
end
```

Python
```python
@rule("Use Supplemental Heat In Office")
@when("Item Office_Temperature changed")
@when("Item Thermostats_Upstairs_Temp changed")
@when("Item Office_Occupied changed")
@when("Item OfficeDoor changed")
def office_heater(event):
  office_temp = ir.getItem("Office_Temperature").getStateAs(QuantityType).toUnit(ImperialUnits.FAHRENHEIT).floatValue()
  hall_temp = items["Thermostats_Upstairs_Temp"].floatValue()
  therm_status = items["Thermostats_Upstairs_Status"].intValue()
  heat_set = items["Thermostats_Upstairs_Heat_Set"].intValue()
  occupied = items["Office_Occupied"]
  door = items["OfficeDoor"]
  difference = hall_temp - office_temp
  logging.warn("Office Temperature: {} Upstairs Hallway Temperature: {} Differnce: {}".format(office_temp,hall_temp,difference))
  logging.warn("Themostat Status: {} Heat Set: {}".format(therm_status,heat_set))
  logging.warn("Office Occupied: {}".format(occupied))
  logging.warn("Office Door: {}".format(door))
  degree_difference = 2.0
  trigger = False
  if heat_set > office_temp:
    if difference > degree_difference:
     if occupied == ON:
      if True:
          if therm_status == 0:
            if door == CLOSED:
                trigger = True
            else:
               logging.warn("Door Open, no action taken")
          else:
            logging.warn("HVAC on, no action taken")
      else:
        logging.warn("Office unoccupied, no action taken")
    else:
      logging.warn("Thermstat and office temperature difference {} is less than {} degrees, no action taken".format(difference, degree_difference))
  else:
    logging.warn("Heat set lower than office temp, no action taken".format(difference, degree_difference))


  if trigger:
    logging.warn("Turning on heater")
    events.sendCommand("Lights_Office_Outlet","ON")
  else:
    logging.warn("Turning off heater")
    events.sendCommand("Lights_Office_Outlet","OFF")
```


Ruby
```ruby
rule 'Use supplemental heat in office' do
  changed Office_Temperature, Thermostats_Upstairs_Temp, Office_Occupied, OfficeDoor
  run { Lights_Office_Outlet << ON }
  only_if Office_Occupied
  only_if { OfficeDoor == CLOSED }
  only_if { Thermostate_Upstairs_Heat_Set > Office_Temperature }
  only_if { unit('°F') { Thermostat_Upstairs_Temp - Office_Temperature > 2 } }
  otherwise { Lights_Office_Outlet << OFF if Lights_Office_Outlet.on? }
end
```


