# @title Rule Conversions

## Conversion Examples

### DSL

```java
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
    snapped = case item.state
              when 0...25 then 25
              when 26...66 then 66
              when 67...100 then 100
              end
    if snapped
      logger.info("Snapping fan #{item.name} to #{snapped}")
      item << snapped
    else
      logger.info("#{item.name} set to snapped percentage, no action taken.")
    end
  end
end
```

### Python

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
  degree_difference = 2.0
  trigger = occupied == ON && door == CLOSED && heat_set > office_temp && difference > degree_difference 

  if trigger:
    events.sendCommand("Lights_Office_Outlet","ON")
  else:
    events.sendCommand("Lights_Office_Outlet","OFF")
```

Ruby

```ruby
rule "Use supplemental heat in office" do
  changed Office_Temperature, Thermostats_Upstairs_Temp, Office_Occupied, OfficeDoor
  run do
    trigger = Office_Occupied.on? &&
              OfficeDoor.closed? &&
              Thermostate_Upstairs_Heat_Set.state > Office_Temperature.state &&
              Thermostat_Upstairs_Temp.state - Office_Temperature.state > 2 | "°F"
    Lights_Office_Outlet.ensure << trigger # send a boolean command to a SwitchItem, but only if it's different
  end
end
```
