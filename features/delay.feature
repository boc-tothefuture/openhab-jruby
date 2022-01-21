Feature:  delay
  Openhab Language with Delay Support

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario: Delay should sleep specified duration between execution elements
    Given a rule
      """
      rule 'Delay sleeps between execution elements' do
        on_start
        run { logger.info("Sleeping") }
        delay 5.seconds
        run { logger.info("Awake") }
      end
      """
    When I deploy the rule
    Then It should log 'Sleeping' within 5 seconds
    But It should not log 'Awake' within 4 seconds
    Then If I wait 3 seconds
    Then It should log 'Awake' within 5 seconds


  Scenario: Multiple delays can be used between execution elements
    Given a rule
      """
      rule 'Multiple delays can exist in a rule' do
        on_start
        run { logger.info("Sleeping") }
        delay 5.seconds
        run { logger.info("Sleeping Again") }
      end
      """
    When I deploy the rule
    Then It should log 'Sleeping' within 5 seconds
    But It should not log 'Sleeping Again' within 3 seconds
    Then If I wait 3 seconds
    Then It should log 'Sleeping Again' within 5 seconds
