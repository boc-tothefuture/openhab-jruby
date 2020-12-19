Feature:  Rule languages supports OpenHAB units of measurement

  Background:
    Given Clean OpenHAB with latest Ruby Libraries
    And group "Numbers"
    And items:
      | type               | name          | state | pattern |
      | Number:Temperature | NumberC       | 23    | %.5f °C |
      | Number:Temperature | NumberF       | 70    | %.5f °F |
      | Number             | Dimensionless | 2     |         |

  Scenario Outline: | converts NumberItem to another unit
    Given code in a rules file
      """
        result = <convert_line>
        logger.info("#{NumberC.id} is #{result} in Fahrenheit")
      """
    When I deploy the rules file
    Then It should log 'NumberC is 73.40 °F in Fahrenheit' within 5 seconds
    Examples:
      | convert_line                        |
      | NumberC \|ImperialUnits::FAHRENHEIT |
      | NumberC \|'°F'                      |

  Scenario Outline: | Creates a Quantity from a Dimensionless NumberItem
    Given code in a rules file
      """
        result = <convert_line>
        logger.info("#{Dimensionless.id} is #{result} in Fahrenheit")
      """
    When I deploy the rules file
    Then It should log 'Dimensionless is 2 °F in Fahrenheit' within 5 seconds
    Examples:
      | convert_line                              |
      | Dimensionless \|ImperialUnits::FAHRENHEIT |
      | Dimensionless \|'°F'                      |

  Scenario Outline: Operators work on quantities of different units
    Given code in a rules file
      """
        result = <code_line>
        logger.info("Result is #{result}")
      """
    When I deploy the rules file
    Then It should log 'Result is <result>' within 5 seconds
    Examples:
      | code_line         | result                               |
      | NumberC - NumberF | 1.8888888888888888888888888888889 °C |
      | NumberF + NumberC | 143.40 °F                            |

  Scenario Outline: Dimensionless Numbers can be used for multiplication and division
    Given code in a rules file
      """
        result = <code_line>
        logger.info("Result is #{result}")
      """
    When I deploy the rules file
    Then It should log 'Result is <result>' within 5 seconds
    Examples:
      | code_line               | result   |
      | NumberF * Dimensionless | 140.0 °F |
      | NumberF / Dimensionless | 35.0 °F  |
      | Dimensionless * NumberF | 140.0 °F |
      | 2 * NumberF             | 140.0 °F |

  Scenario Outline: Comparisons work on dimensioned number items with different, but comparable units.
    Given code in a rules file
      """
        result = <code_line>
        logger.info("Result is #{result}")
      """
    When I deploy the rules file
    Then It should log 'Result is <result>' within 5 seconds
    Examples:
      | code_line         | result |
      | NumberC > NumberF | true   |

  Scenario Outline: Comparisons work with dimensioned numbers and strings representing quantities
    Given code in a rules file
      """
        result = <code_line>
        logger.info("Result is #{result}")
      """
    When I deploy the rules file
    Then It should log 'Result is <result>' within 5 seconds
    Examples:
      | code_line          | result |
      | NumberC > '4 °F'   | true   |
      | NumberC == '23 °C' | true   |


  Scenario Outline: Each unit needs to be normalized for all operations when combining operators with comparitors.
    Given code in a rules file
      """
        result = <code_line>
        logger.info("Result is #{result}")
      """
    When I deploy the rules file
    Then It should log 'Result is <result>' within 5 seconds
    Examples:
      | code_line                                    | result |
      | (NumberC \|'°F') - (NumberF \|'°F') < '4 °F' | true   |

  Scenario Outline: unit block should convert all units and numbers to a specific unit for all operations
    Given code in a rules file
      """
        result = <code_line>
        logger.info("Result is #{result}")
      """
    When I deploy the rules file
    Then It should log 'Result is <result>' within 5 seconds
    Examples:
      | code_line                                                         | result                                |
      | unit('°F') { NumberC - NumberF < 4 }                              | true                                  |
      | unit('°F') { NumberC - '24 °C' < 4 }                              | true                                  |
      | unit('°F') { Quantity.new('24 °C') - NumberC < 4 }                | true                                  |
      | unit('°C') { NumberF - '20 °C' < 2 }                              | true                                  |
      | unit('°C') { NumberF - Dimensionless  }                           | 19.1111111111111111111111111111111 °C |
      | unit('°C') { NumberC + NumberF  }                                 | 44.1111111111111111111111111111111 °C |
      | unit('°C') { NumberF - Dimensionless < 20 }                       | true                                  |
      | unit('°C') { Dimensionless + NumberC == 25 }                      | true                                  |
      | unit('°C') { 2 + NumberC == 25 }                                  | true                                  |
      | unit('°C') { Dimensionless * NumberC == 46 }                      | true                                  |
      | unit('°C') { 2 * NumberC == 46 }                                  | true                                  |
      | unit('°C') { ( (2 * (NumberF + NumberC) ) / Dimensionless ) < 45} | true                                  |
      | unit('°C') { [NumberC, NumberF, Dimensionless].min }              | 2                                     |


