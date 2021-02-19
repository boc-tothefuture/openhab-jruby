Feature:  decimal_type
  Rule languages supports extensions to DecimalType

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario: DecimalType can be converted to Quantity
    Given code in a rules file
      """
      java_import org.openhab.core.library.types.DecimalType
      logger.info("DecimalType to °C: #{DecimalType.new(10)|"°C"} equals quantity: #{DecimalType.new(10)|"°C" == Quantity.new('10°C')}")
      """
    When I deploy the rules file
    Then It should log "DecimalType to °C: 10 °C equals quantity: true" within 5 seconds


