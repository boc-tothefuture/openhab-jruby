Feature:  timer
  Openhab Timer Support

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario: Timers can be created with `after`
    Given code in a rules file
      """
      after 5.seconds do
        logger.info("Timer Fired")
      end
      """
    When I deploy the rules file
    Then It should not log 'Timer Fired' within 4 seconds
    But if I wait 2 seconds
    Then It should log 'Timer Fired' within 5 seconds

  Scenario: Timers support non-integral durations
    Given code in a rules file
      """
      after 2.5.seconds do
        logger.info("Timer Fired")
      end
      """
    When I deploy the rules file
    Then It should not log 'Timer Fired' within 1 seconds
    But if I wait 3 seconds
    Then It should log 'Timer Fired' within 5 seconds

  Scenario: Timers support 'active?', 'running?' and 'terminated?'
    Given code in a rules file
      """
      timer = after 1.ms do |timer|
        logger.info("Timer Active: #{timer.active?}")
        logger.info("Timer Running: #{timer.running?}")
      end
      after 2.second do
        logger.info("Timer Terminated: #{timer.terminated?}")
      end
      """
    When I deploy the rules file
    Then It should log 'Timer Active: true' within 5 seconds
    Then It should log 'Timer Running: true' within 5 seconds
    Then It should log 'Timer Terminated: true' within 5 seconds


  Scenario: Timers work inside of rules
    Given a rule
      """
      rule 'test timers' do
      on_start
      run do
       after 5.seconds do
         logger.info("Timer Fired")
       end
      end
      end
      """
    When I deploy the rules file
    Then It should not log 'Timer Fired' within 4 seconds
    But if I wait 2 seconds
    Then It should log 'Timer Fired' within 5 seconds

  Scenario: Timers have access to OpenHAB timer methods
    Given code in a rules file
      """
      after 1.second do |timer|
        logger.info("Timer is active? #{timer.is_active}")
      end
      """
    When I deploy the rules file
    Then It should log 'Timer is active? true' within 5 seconds


  Scenario: Timers can be rescheduled
    Given code in a rules file
      """
      count = 0
      after 3.seconds do |timer|
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
      after 3.seconds do |timer|
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
    Then It should not log 'Timer Fired' within 3 seconds
    And if I wait 3 seconds
    Then It should log 'Timer Fired' within 5 seconds


  Scenario: Timers can be created without using the after syntax
    Given code in a rules file
      """
      Timer.new(duration: 1.second) do |timer|
        logger.info("Timer is active? #{timer.is_active}")
      end
      """
    When I deploy the rules file
    Then It should log 'Timer is active? true' within 5 seconds

  Scenario: Timers in rules are cancelled if the script is removed
    Given a rule:
      """
      rule 'test timers' do
        on_start
        run do
          logger.info("Rule Started")
          after 5.seconds do
            logger.info("Timer Fired")
           end
        end
      end
      """
    When I deploy the rules file
    Then It should log 'Rule Started' within 5 seconds
    When I wait 2 seconds
    And I remove the rules file
    Then It should not log 'Timer Fired' within 10 seconds

  Scenario: Timers in script are cancelled if the script is removed
    Given code in a rules file:
      """
      logger.info("Rule Started")
      after 5.seconds do
        logger.info("Timer Fired")
      end
      """
    When I deploy the rules file
    Then It should log 'Rule Started' within 5 seconds
    When I wait 2 seconds
    And I remove the rules file
    Then It should not log 'Timer Fired' within 10 seconds
    

