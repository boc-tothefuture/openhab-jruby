Feature:  number_item
  Rule languages supports Number Items

  Background:
    Given Clean OpenHAB with latest Ruby Libraries
    And group "Numbers"
    And items:
      | type   | name      | label      | group   | state |
      | Number | NumberOne | Number One | Numbers | 0     |
      | Number | NumberTwo | Number Two | Numbers | 70    |

  Scenario Outline: NumberItem supports math operations
    Given item "NumberOne" state is changed to "<initial>"
    And code in a rules file
      """
      NumberOne << NumberOne<operator> <operand>
      """
    When I deploy the rules file
    Then "NumberOne" should be in state "<final>" within 5 seconds
    Examples:
      | initial | operator | operand | final |
      | 50      | +        | 2       | 52    |
      | 50      | -        | 2       | 48    |
      | 50      | /        | 2       | 25    |
      | 50      | *        | 2       | 100   |
      | 50      | +        | 2.0     | 52    |
      | 50      | -        | 2.0     | 48    |
      | 50      | /        | 2.0     | 25    |
      | 50      | *        | 2.0     | 100   |

  Scenario Outline: NumberItem can be coerced to support opertations from Ruby number types
    Given item "NumberOne" state is changed to "<initial>"
    And code in a rules file
      """
      NumberOne << <operand> <operator> NumberOne
      """
    When I deploy the rules file
    Then "NumberOne" should be in state "<final>" within 5 seconds
    Examples:
      | initial | operator | operand | final |
      | 50      | +        | 2       | 52    |
      | 50      | -        | 2       | -48   |
      | 50      | /        | 2       | 0.04  |
      | 50      | *        | 2       | 100   |
      | 50      | +        | 2.0     | 52    |
      | 50      | -        | 2.0     | -48   |
      | 50      | /        | 2.0     | 0.04  |
      | 50      | *        | 2.0     | 100   |

  Scenario: to_d provides a BigDecimal class for math operations
    Given code in a rules file
      """
      logger.info("to_d returns #{NumberOne.to_d.class}")
      """
    When I deploy the rules file
    Then It should log "to_d returns BigDecimal" within 5 seconds

  Scenario: to_i provides an Integer class for math operations
    Given code in a rules file
      """
      logger.info("to_i returns #{NumberOne.to_i.class}")
      """
    When I deploy the rules file
    Then It should log "to_i returns Integer" within 5 seconds

  Scenario: to_f provides a Float class for math operations
    Given code in a rules file
      """
      logger.info("to_f returns #{NumberOne.to_f.class}")
      """
    When I deploy the rules file
    Then It should log "to_f returns Float" within 5 seconds

  Scenario: NumberItem should work with grep
    Given code in a rules file
      """
      # Get all NumberItems
      items.grep(NumberItem)
           .each { |number| logger.info("#{number.id} is a Number Item") }
      """
    When I deploy the rules file
    Then It should log "Number One is a Number Item" within 5 seconds
    And It should log "Number Two is a Number Item" within 5 seconds


  Scenario: NumberItem should work with grep ranges
    Given code in a rules file
      """
      # Get all NumberItems less than 50
      Numbers.grep(0...50)
           .each { |number| logger.info("#{number.id} is less than 50") }
      """
    When I deploy the rules file
    Then It should log "Number One is less than 50" within 5 seconds
    But It should not log "Number Two is less than 50" within 5 seconds


  Scenario: NumberItem states work in cases
    Given code in a rules file
      """
      #Check if number items is less than 50
      case NumberOne
      when (0...50)
        logger.info("#{NumberOne.id} is less than 50")
      when (50..100)
        logger.info("#{NumberOne.id} is greater than 50")
      end
      """
    When I deploy the rules file
    Then It should log "Number One is less than 50" within 5 seconds

  Scenario: NumberItem states is compareble to floats
    Given code in a rules file
      """
      #Check if number items is less than 50
      if (0.0...50.0).include?(NumberOne)
        logger.info("#{NumberOne.id} is in range (0.0...50.0)")
      end
      """
    When I deploy the rules file
    Then It should log "Number One is in range (0.0...50.0)" within 5 seconds

  Scenario: NumberItem has methods from Numeric
    Given code in a rules file
      """
      logger.info("Number Two is positive? #{NumberTwo.positive?}")
      """
    When I deploy the rules file
    Then It should log "Number Two is positive? true" within 5 seconds

  Scenario: NumberItem can be converted to QuantityType
    Given code in a rules file
      """
      logger.info("NumberTwo to °C: #{NumberTwo|"°C"} equals quantity: #{NumberTwo|"°C" == QuantityType.new('70°C')}")
      """
    When I deploy the rules file
    Then It should log "NumberTwo to °C: 70 °C equals quantity: true" within 5 seconds


