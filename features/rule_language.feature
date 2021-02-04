Feature: rule_language
  Rule language generic support

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario: Call function from rule
    Given code in a rules file
      """
      def outer_function(message)
        logger.info("Outer Function #{message}")
      end

      rule 'Test Outer Function' do
        on_start
        run { outer_function("Test123") }
      end
      """
    When I deploy the rules file
    Then It should log 'Outer Function Test123' within 5 seconds

  Scenario: Iterate over group using array methods directly on group object
    Given group "GarageDoors"
    And items:
      | type    | name      | label      | group       | state  |
      | Contact | LeftDoor  | Left Door  | GarageDoors | OPEN   |
      | Contact | RightDoor | Right Door | GarageDoors | CLOSED |
    And code in a rules file
      """
      open_doors = GarageDoors.select(&:open?)
      open_doors.each { | door | logger.warn("Garage Door #{door.id} is OPEN") }
      """
    When I deploy the rules file
    Then It should log 'Garage Door Left Door is OPEN' within 5 seconds

  Scenario: Number ranges should work with dimmer values
    Given items:
      | type   | name       | label         | state |
      | Dimmer | TestDimmer | Dimmer Switch | 55    |
    And code in a rules file
      """
      case TestDimmer
      when 0...50
       logger.info("#{TestDimmer.id} Less than 50")
      when 50..100
       logger.info("#{TestDimmer.id} More than 50")
      else
       logger.info("#{TestDimmer} Not matched")
      end
      """
    When I deploy the rules file
    Then It should log 'More than 50' within 5 seconds

  Scenario: Grep should work on Items by ItemType
    Given items:
      | type   | name       | label         | state |
      | Dimmer | TestDimmer | Dimmer Switch | 55    |
    And code in a rules file
      """
      items.grep(Dimmer)
           .each { |item| logger.info("Found #{item.label}")}
      """
    When I deploy the rules file
    Then It should log 'Found Dimmer Switch' within 5 seconds

  Scenario: Rule supports executing different block if guards are not satisfied
    Given items:
      | type   | name       | state |
      | Switch | TestSwitch | ON    |
    And a rule
      """
      rule 'Execute otherwise if guard is not satisfied' do
        on_start
        run { TestSwitch << ON }
        otherwise { TestSwitch << OFF }
        only_if { false }
      end
      """
    When I deploy the rule
    Then "TestSwitch" should be in state "OFF" within 5 seconds


  Scenario: Rule logs a warning and isn't created if it contains no execution blocks
    Given a rule
      """
      rule 'No execution blocks' do
        on_start
      end
      """
    When I deploy the rule
    Then It should log 'has no execution blocks, not creating rule' within 5 seconds