Feature:  Rule languages supports Switches

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario Outline: Switches respond to off/on and off?/on?
    Given items:
      | type   | name       | label       | state           |
      | Switch | TestSwitch | Test Switch | <initial_state> |
    And code in a rules file
      """
      # Invert all switches
      items.select { |item| item.is_a? Switch }
           .each   { |item| if item.off? then item.on else item.off end}
      """
    When I deploy the rules file
    Then "TestSwitch" should be in state "<final_state>" within 5 seconds

    Examples:
      | initial_state | final_state |
      | ON            | OFF         |
      | OFF           | ON          |

  Scenario: Switches respond to grep
    Given items:
      | type   | name       | label       | state |
      | Switch | TestSwitch | Test Switch | ON    |
    And code in a rules file
      """
      # Invert all switches
      items.grep(Switch)
           .each { |item| logger.info("#{TestSwitch} found") }
      """
    When I deploy the rules file
    Then It should log 'Test Switch found' within 5 seconds


