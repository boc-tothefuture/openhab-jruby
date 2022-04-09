Feature:  quantity_type
  Rule languages supports OpenHAB support Quantities

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario Outline: QuantityType is constructuble with | from numeric
    Given code in a rules file
      """
        logger.info("Result is #{(<quantity>).format('%.1f %unit%')}")
      """
    When I deploy the rules file
    Then It should log 'Result is <result>' within 5 seconds
    Examples:
      | quantity       | result  |
      | 50 \|'°F'      | 50.0 °F |
      | 50.0 \|'°F'    | 50.0 °F |
      | 50.to_d \|'°F' | 50.0 °F |

  Scenario Outline: QuantityType is constructuble with | from numeric from within rule
    Given items:
      | type   | name        | state |
      | Number | NumberItem1 | 0     |
    And code in a rules file
      """
        rule '| test' do
          changed NumberItem1
          run { logger.info("Result is #{(<quantity>).format('%.1f %unit%')}") }
        end
      """
    When I deploy the rules file
    And item "NumberItem1" state is changed to "1"
    Then It should log 'Result is <result>' within 5 seconds
    Examples:
      | quantity       | result  |
      | 50 \|'°F'      | 50.0 °F |
      | 50.0 \|'°F'    | 50.0 °F |
      | 50.to_d \|'°F' | 50.0 °F |

  Scenario Outline: Numeric item triggers NoMethodError when | is applied to a NULL/UNDEF state
    Given items:
      | type   | name        | state   |
      | Number | NumberItem1 | <state> |
    And code in a rules file
      """
        begin
          NumberItem1 | 'W'
          logger.info("All Good!")
        rescue NoMethodError
          logger.info("NoMethodError caught!")
        end
      """
    When I deploy the rules file
    Then It should log '<result>' within 5 seconds
    Examples:
      | state | result                |
      | NULL  | NoMethodError caught! |
      | UNDEF | NoMethodError caught! |
      | 10    | All Good!             |

  Scenario Outline: QuantityType responds to math operations where operand is a quantity type
    Given code in a rules file
      """
        logger.debug("<quantity> <operator> <operand> = <result>")
        result = <quantity> <operator> <operand>
        logger.info("Result is #{result.format('%.1f %unit%')}")
      """
    When I deploy the rules file
    Then It should log 'Result is <result>' within 5 seconds
    Examples:
      | quantity                   | operator | operand                    | result   |
      | QuantityType.new('50 °F')  | +        | QuantityType.new('50 °F')  | 100.0 °F |
      | QuantityType.new('50 °F')  | -        | QuantityType.new('25 °F')  | 25.0 °F  |
      | QuantityType.new('100 °F') | /        | QuantityType.new('2 °F')   | 50.0     |
      | QuantityType.new('50 °F')  | +        | -QuantityType.new('25 °F') | 25.0 °F  |


  Scenario Outline: QuantityType responds to math operations where operand is a string
    Given code in a rules file
      """
        result = <quantity><operator> <operand>
        logger.info("Result is #{result.format('%.1f %unit%')}")
      """
    When I deploy the rules file
    Then It should log 'Result is <result>' within 5 seconds
    Examples:
      | quantity                  | operator | operand | result   |
      | QuantityType.new('50 °F') | +        | '50 °F' | 100.0 °F |
      | QuantityType.new('50 °F') | -        | '25 °F' | 25.0 °F  |


  Scenario Outline: QuantityType responds to math operations where operand is Numeric
    Given code in a rules file
      """
        result = <quantity><operator> <operand>
        logger.info("Result is #{result.format('%.1f %unit%')}")
      """
    When I deploy the rules file
    Then It should log 'Result is <result>' within 5 seconds
    Examples:
      | quantity                   | operator | operand | result   |
      | QuantityType.new('50 °F')  | *        | 2       | 100.0 °F |
      | QuantityType.new('100 °F') | /        | 2       | 50.0 °F  |
      | QuantityType.new('50 °F')  | *        | 2.0     | 100.0 °F |
      | QuantityType.new('100 °F') | /        | 2.0     | 50.0 °F  |

  Scenario Outline: QuantityType responds to math operations where operand is a NumberItem with or without dimensions
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
      | quantity                  | operator | operand       | result   |
      | QuantityType.new('50 °F') | +        | NumberF       | 52.0 °F  |
      | QuantityType.new('50 °F') | *        | Dimensionless | 100.0 °F |
      | QuantityType.new('50 °F') | /        | Dimensionless | 25.0 °F  |



  Scenario Outline: Quantity types can be compared
    Given code in a rules file
      """
        result = <quantity> <comparator> <compare_to>
        logger.info("Result is #{result}")
      """
    When I deploy the rules file
    Then It should log 'Result is <result>' within 5 seconds
    Examples:
      | quantity                  | comparator | compare_to                 | result |
      | QuantityType.new('50 °F') | >          | QuantityType.new('25 °F')  | true   |
      | QuantityType.new('50 °F') | >          | QuantityType.new('525 °F') | false  |
      | QuantityType.new('50 °F') | >=         | QuantityType.new('50 °F')  | true   |
      | QuantityType.new('50 °F') | ==         | QuantityType.new('50 °F')  | true   |
      | QuantityType.new('50 °F') | <          | QuantityType.new('25 °C')  | true   |

  Scenario Outline: QuantityType can be compared and the compare-to can be a string
    Given code in a rules file
      """
        result = <quantity> <comparator> <compare_to>
        logger.info("Result is #{result}")
      """
    When I deploy the rules file
    Then It should log 'Result is <result>' within 5 seconds
    Examples:
      | quantity                  | comparator | compare_to | result |
      | QuantityType.new('50 °F') | ==         | '50 °F'    | true   |
      | QuantityType.new('50 °F') | <          | '25 °C'    | true   |

  Scenario Outline: QuantityType responds to math operations where operand is DecimalType
    Given code in a rules file
      """
        java_import org.openhab.core.library.types.DecimalType
        result = <quantity><operator> <operand>
        logger.info("Result is #{result.format('%.1f %unit%')}")
      """
    When I deploy the rules file
    Then It should log 'Result is <result>' within 5 seconds
    Examples:
      | quantity                   | operator | operand              | result   |
      | QuantityType.new('50 °F')  | *        | DecimalType.new(2)   | 100.0 °F |
      | QuantityType.new('100 °F') | /        | DecimalType.new(2)   | 50.0 °F  |
      | QuantityType.new('50 °F')  | *        | DecimalType.new(2.0) | 100.0 °F |
      | QuantityType.new('100 °F') | /        | DecimalType.new(2.0) | 50.0 °F  |

  Scenario Outline: QuantityType responds to positive?, negative?, and zero?
    Given items:
      | type               | name      | state  | pattern |
      | Number:Temperature | NumberF   | 2 °F   | %d °F   |
      | Number:Temperature | NumberC   | 2 °C   | %d °C   |
      | Number:Power       | PowerPos  | 100 W  |         |
      | Number:Power       | PowerNeg  | -100 W |         |
      | Number:Power       | PowerZero | 0 W    |         |
      | Number             | Number1   | 20     |         |
    And code in a rules file
      """
      logger.info("<object>.<test> #{<object>.<test>}")
      """
    When I deploy the rules file
    Then It should log "<object>.<test> <result>" within 5 seconds
    Examples:
      | object                    | test      | result |
      | QuantityType.new('50°F')  | positive? | true   |
      | QuantityType.new('-50°F') | negative? | true   |
      | QuantityType.new('10W')   | positive? | true   |
      | QuantityType.new('-1kW')  | positive? | false  |
      | QuantityType.new('0W')    | zero?     | true   |
      | NumberF                   | positive? | true   |
      | NumberC                   | negative? | false  |
      | PowerPos                  | positive? | true   |
      | PowerNeg                  | negative? | true   |
      | PowerZero                 | zero?     | true   |
      | Number1                   | positive? | true   |

  Scenario Outline: QuantityType can be converted to another unit with |
    Given code in a rules file
      """
      quantity = <source>|'<unit1>'
      quantity = quantity|'<unit2>'
      logger.info("quantity in the target unit is #{quantity.to_i}")
      """
    When I deploy the rules file
    Then It should log "quantity in the target unit is <target>" within 5 seconds
    Examples:
      | source | unit1 | unit2 | target |
      | 0      | °C    | °F    | 32     |
      | 1      | h     | s     | 3600   |

  Scenario Outline: Triggers support ranges with string quantity
    Given items:
      | type         | name       | state     |
      | Number:Power | Item_Power | <initial> |
    And a rule:
      """
      rule 'Execute rule with range conditions' do
        <trigger> Item_Power, <conditions>
        run { |event| logger.info("Item Power: <trigger>") }
      end
      Item_Power << '<change>'
      """
    When I deploy the rule
    Then It <should> log "Item Power: <trigger>" within 5 seconds
    Examples: From range
      | trigger | initial | conditions          | change | should     |
      | changed | 0 W     | from: '0 W'..'10 W' | 14 W   | should     |
      | changed | 12 W    | from: '0 W'..'10 W' | 10 W   | should not |
      | changed | 0 W     | to: '0 W'..'10 W'   | 14 W   | should not |
      | changed | 0 W     | to: '0 W'..'10 W'   | 10 W   | should     |
      | updated | 0 W     | to: '0 W'..'10 W'   | 10 W   | should     |
      | updated | 0 W     | to: '0 W'..'10 W'   | 14 W   | should not |
