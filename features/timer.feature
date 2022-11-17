Feature:  timer
  Openhab Timer Support

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario: Timers in script are cancelled if the script is removed
    Given a rule:
      """
      logger.info("Rule Started")
      after 5.seconds do
        logger.info("Timer Fired")
      end
      """
    When I deploy the rules file
    Then It should log 'Rule Started' within 5 seconds
    And I remove the rules file
    Then It should not log 'Timer Fired' within 10 seconds
