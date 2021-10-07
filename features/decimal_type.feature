Feature:  decimal_type
  Rule languages supports extensions to DecimalType

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario: DecimalType can be converted to QuantityType
    Given code in a rules file
      """
      java_import org.openhab.core.library.types.DecimalType
      logger.info("DecimalType to °C: #{DecimalType.new(10)|"°C"} equals quantity: #{DecimalType.new(10)|"°C" == QuantityType.new('10°C')}")
      """
    When I deploy the rules file
    Then It should log "DecimalType to °C: 10 °C equals quantity: true" within 5 seconds

  Scenario: DecimalType is inspectable
    Given code in a rules file
      """
      java_import org.openhab.core.library.types.DecimalType
      logger.info("DecimalType inspected: #{DecimalType.new(10).inspect}")
      """
    When I deploy the rules file
    Then It should log "DecimalType inspected: 10" within 5 seconds

  Scenario Outline: DecimalType has numeric predicates
    Given code in a rules file
      """
      java_import org.openhab.core.library.types.DecimalType
      logger.info("DecimalType is <predicate>: #{DecimalType.new(<value>).<predicate>}")
      """
    When I deploy the rules file
    Then It should log "DecimalType is <predicate>: <result>" within 5 seconds
    Examples:
      | value | predicate  | result |
      | 0     | zero?      | true   |
      | 0     | positive?  | false  |
      | 0     | negative?  | false  |
      | 1     | zero?      | false  |
      | 1     | positive?  | true   |
      | 1     | negative?  | false  |
      | -1    | zero?      | false  |
      | -1    | positive?  | false  |
      | -1    | negative?  | true   |
