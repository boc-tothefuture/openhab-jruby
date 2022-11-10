Feature:  timer
  Openhab Timer Support

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

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
    And I remove the rules file
    Then It should not log 'Timer Fired' within 10 seconds

  Scenario: Timers with IDs specified are reeentrant
    Given items:
      | type   | name       | label      |
      | Number | Alarm_Mode | Alarm Mode |
    And a deployed rule:
      """
      rule "Execute rule when item is changed and is modified during specified duration" do
        changed Alarm_Mode
        triggered do |item|
          logger.info("Alarm Mode Updated")
          after 10.seconds, id: item do
            logger.info("Timer Fired")
          end
        end
      end
      """
    When item "Alarm_Mode" state is changed to "14"
    Then It should log 'Alarm Mode Updated' within 2 seconds
    And If I wait 5 seconds
    And item "Alarm_Mode" state is changed to "10"
    Then It should not log 'Timer Fired' within 9 seconds
    But If I wait 3 seconds
    Then It should log 'Timer Fired' within 5 seconds


  Scenario: Timers can be retrieved by id
    Given code in a rules file:
      """
      after 3.seconds, :id => :foo do
        logger.info "Timer Fired"
      end

      rule 'Cancel timer' do
        run { timers[:foo]&.cancel }
        on_start true
      end
      """
    When I deploy the rule
    Then It should not log 'Timer Fired' within 5 seconds

  Scenario: Reentrant timer will change its duration to the latest call
    Given code in a rules file
      """
      [10, 5, 1].each do |duration|
        after duration.seconds, id: :test do
          logger.info("Timer Fired after #{duration} seconds")
        end
      end
      """
    When I deploy the rules file
    Then It should log 'Timer Fired after 1 seconds' within 2 seconds
    And It should not log 'Timer Fired after 5 seconds' within 7 seconds
    And It should not log 'Timer Fired after 10 seconds' within 12 seconds

  Scenario: Timer is removed from timers[] when cancelled
    Given code in a rules file:
      """
      after 3.seconds, :id => :foo do
        logger.info "Timer Fired"
      end

      rule 'Cancel timer' do
        on_start true
        run do
          logger.info("timers[:foo] is nil before cancel: #{timers[:foo].nil?}")
          timers[:foo]&.cancel
          logger.info("timers[:foo] is nil after cancel: #{timers[:foo].nil?}")
        end
      end
      """
    When I deploy the rule
    Then It should log 'timers[:foo] is nil before cancel: false' within 5 seconds
    And It should log 'timers[:foo] is nil after cancel: true' within 5 seconds

  Scenario: Managed timers can be rescheduled
    Given code in a rules file:
      """
      after 1.hours, :id => :foo do
        logger.info "Timer Fired"
      end

      rule 'Cancel timer' do
        on_start
        run do
          timers[:foo]&.reschedule 1.second
        end
      end
      """
    When I deploy the rule
    Then It should log 'Timer Fired' within 5 seconds

