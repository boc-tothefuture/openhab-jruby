Feature:  Rule language generic support

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
      open_doors.each { | door | logger.warn("Garage Door #{door} is OPEN") }
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
       logger.info("#{TestDimmer} Less than 50")
      when 50..100
       logger.info("#{TestDimmer} More than 50")
      else
       logger.info("#{TestDimmer.state} Not matched")
      end
      """
    When I deploy the rules file
    Then It should log 'More than 50' within 5 seconds

  Scenario: Items should provide their label if they have one when converted to a string
  Scenario: Items should provide their name if they don't have a label one when converted to a string

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


  Scenario: Rule supports executing if guards block execution
    Given a rule
      """
      rule 'Execute block if guards fail' do
        run :always, { Lights_Office_Outlet << ON } .  # We need to pass in a boolean if guards failed?
        otherwise { Lights_Office_Outlet << OFF if Lights_Office_Outlet.on? } #  How do otherwise interact with each other and or delays? Are delays linked? you could want to skip delays if otherwise?
      end
      """
    Then It should log 'Not Implemented' within 5 seconds