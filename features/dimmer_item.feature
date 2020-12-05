Feature:  Rule languages supports Dimmers

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario Outline: Dimmer should work with grep
    Given items:
      | type   | name       | label       | state |
      | Dimmer | DimmerTest | Test Dimmer | 45    |
    And code in a rules file
      """
      # Get dimmers with a state of less than 50
      items.grep(Dimmer)
           .grep(0...50)
           .each { |item| logger.info("#{item} is less than 50") }
      """
    When I deploy the rules file
    Then It should log 'Test Dimmer is less than 50' within 5 seconds

  Scenario Outline: Dimmer should work with grep
    Given items:
      | type   | name       | label       | state |
      | Dimmer | DimmerTest | Test Dimmer | 45    |
    And code in a rules file
      """
      # Get dimmers with a state of less than 50
      items.grep(Dimmer)
           .grep(0...50)
           .each { |item| logger.info("#{item} is less than 50") }
      """
    When I deploy the rules file
    Then It should log 'Test Dimmer is less than 50' within 5 seconds
