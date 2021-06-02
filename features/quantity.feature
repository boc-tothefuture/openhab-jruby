Feature:  quantity
  Rule languages supports OpenHAB support Quantities

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario Outline: Quantity responds to math operations where operand is a quantity type
    Given code in a rules file
      """
        logger.debug("<quantity> <operator> <operand> = <result>")
        result = <quantity> <operator> <operand>
        logger.info("Result is #{result.format('%.1f %unit%')}")
      """
    When I deploy the rules file
    Then It should log 'Result is <result>' within 5 seconds
    Examples:
      | quantity               | operator | operand                | result   |
      | Quantity.new('50 °F')  | +        | Quantity.new('50 °F')  | 100.0 °F |
      | Quantity.new('50 °F')  | -        | Quantity.new('25 °F')  | 25.0 °F  |
      | Quantity.new('100 °F') | /        | Quantity.new('2 °F')   | 50.0     |
      | Quantity.new('50 °F')  | +        | -Quantity.new('25 °F') | 25.0 °F  |


  Scenario Outline: Quantity responds to math operations where operand is a string
    Given code in a rules file
      """
        result = <quantity><operator> <operand>
        logger.info("Result is #{result.format('%.1f %unit%')}")
      """
    When I deploy the rules file
    Then It should log 'Result is <result>' within 5 seconds
    Examples:
      | quantity               | operator | operand | result   |
      | Quantity.new('50 °F')  | +        | '50 °F' | 100.0 °F |
      | Quantity.new('50 °F')  | -        | '25 °F' | 25.0 °F  |
      | Quantity.new('100 °F') | /        | '2 °F'  | 50.0     |


  Scenario Outline: Quantity responds to math operations where operand is Numeric
    Given code in a rules file
      """
        result = <quantity><operator> <operand>
        logger.info("Result is #{result.format('%.1f %unit%')}")
      """
    When I deploy the rules file
    Then It should log 'Result is <result>' within 5 seconds
    Examples:
      | quantity               | operator | operand | result   |
      | Quantity.new('50 °F')  | *        | 2       | 100.0 °F |
      | Quantity.new('100 °F') | /        | 2       | 50.0 °F  |
      | Quantity.new('50 °F')  | *        | 2.0     | 100.0 °F |
      | Quantity.new('100 °F') | /        | 2.0     | 50.0 °F  |

  Scenario Outline: Quantity responds to math operations where operand is a NumberItem with or without dimensions
    Given items:
      | type               | name          | label                | state | pattern |
      | Number:Temperature | NumberF       | Number Fahrenheit    | 2     | %.5f °F |
      | Number:Temperature | NumberC       | Number Celsius       | 2     | %.5f °C |
      | Number             | Dimensionless | Number Dimensionless | 2     |         |
    And code in a rules file
      """
        result = <quantity> <operator> <operand>
        logger.info("Result is #{result.format('%.1f %unit%')}")
      """
    When I deploy the rules file
    Then It should log 'Result is <result>' within 5 seconds
    Examples:
      | quantity              | operator | operand       | result   |
      | Quantity.new('50 °F') | +        | NumberF       | 52.0 °F  |
      | Quantity.new('50 °F') | *        | Dimensionless | 100.0 °F |
      | Quantity.new('50 °F') | /        | Dimensionless | 25.0 °F  |



  Scenario Outline: Quantities can be compared
    Given code in a rules file
      """
        result = <quantity> <comparator> <compare_to>
        logger.info("Result is #{result}")
      """
    When I deploy the rules file
    Then It should log 'Result is <result>' within 5 seconds
    Examples:
      | quantity              | comparator | compare_to             | result |
      | Quantity.new('50 °F') | >          | Quantity.new('25 °F')  | true   |
      | Quantity.new('50 °F') | >          | Quantity.new('525 °F') | false  |
      | Quantity.new('50 °F') | >=         | Quantity.new('50 °F')  | true   |
      | Quantity.new('50 °F') | ==         | Quantity.new('50 °F')  | true   |
      | Quantity.new('50 °F') | <          | Quantity.new('25 °C')  | true   |

  Scenario Outline: Quantity can be compared and the compare-to can be a string
    Given code in a rules file
      """
        result = <quantity> <comparator> <compare_to>
        logger.info("Result is #{result}")
      """
    When I deploy the rules file
    Then It should log 'Result is <result>' within 5 seconds
    Examples:
      | quantity              | comparator | compare_to | result |
      | Quantity.new('50 °F') | ==         | '50 °F'    | true   |
      | Quantity.new('50 °F') | <          | '25 °C'    | true   |

  Scenario Outline: Quantity responds to math operations where operand is DecimalType
    Given code in a rules file
      """
        java_import org.openhab.core.library.types.DecimalType
        result = <quantity><operator> <operand>
        logger.info("Result is #{result.format('%.1f %unit%')}")
      """
    When I deploy the rules file
    Then It should log 'Result is <result>' within 5 seconds
    Examples:
      | quantity               | operator | operand              | result   |
      | Quantity.new('50 °F')  | *        | DecimalType.new(2)   | 100.0 °F |
      | Quantity.new('100 °F') | /        | DecimalType.new(2)   | 50.0 °F  |
      | Quantity.new('50 °F')  | *        | DecimalType.new(2.0) | 100.0 °F |
      | Quantity.new('100 °F') | /        | DecimalType.new(2.0) | 50.0 °F  |
