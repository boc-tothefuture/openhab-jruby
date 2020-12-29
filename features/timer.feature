Feature:  Openhab Timer Support

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario: Timers can be created with `after`
    Given code in a rules file
      """
      after(5.seconds) do
        logger.info("Timer Fired")
      end
      """
    When I deploy the rules file
    Then It should not log 'Timer Fired' within 4 seconds
    But if I wait 2 seconds
    Then It should log 'Timer Fired' within 5 seconds

  Scenario: Timers have access to OpenHAB timer methods
    Given code in a rules file
      """
      after(1.seconds) do |timer|
        logger.info("Timer is active? #{timer.is_active}")
      end
      """
    When I deploy the rules file
    Then It should log 'Timer is active? true' within 5 seconds


  Scenario: Timers can be rescheduled
    Given code in a rules file
      """
      count = 0
      after(3.seconds) do |timer|
        if count > 0
          logger.info("Timer Fired")
        else
          logger.info("Rescheduling")
          timer.reschedule
        end
        count += 1
      end
      """
    When I deploy the rules file
    Then It should not log 'Timer Fired' within 4 seconds
    But It should log 'Rescheduling' within 4 seconds
    And if I wait 2 seconds
    Then It should log 'Timer Fired' within 5 seconds

  Scenario: Timers can be rescheduled for different times
    Given code in a rules file
      """
      count = 0
      after(3.seconds) do |timer|
        if count > 0
          logger.info("Timer Fired")
        else
          logger.info("Rescheduling")
          timer.reschedule 5.seconds
        end
        count += 1
      end
      """
    When I deploy the rules file
    Then It should not log 'Timer Fired' within 4 seconds
    But It should log 'Rescheduling' within 4 seconds
    Then It should not log 'Timer Fired' within 4 seconds
    And if I wait 2 seconds
    Then It should log 'Timer Fired' within 5 seconds


