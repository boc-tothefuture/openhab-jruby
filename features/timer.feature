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

  Scenario: Timers can be created with create_timer
    Given code in a rules file
      """
      create_timer 5.seconds do
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

  Scenario: Timers support number items
    Given items:
      | type   | name       | label      | state   |
      | Number | Alarm_Time | Alarm Mode | <state> |
    And code in a rules file
      """
      after Alarm_Time do
        logger.info("Timer Fired")
      end
      """
    When I deploy the rules file
    Then It should not log 'Timer Fired' within 4 seconds
    Then It should log 'Timer Fired' within 3 seconds

    Examples: Works with different numbers
      | state |
      | 5     |
      | 5.5   |

  Scenario: Timers support custom user provided objects
    Given code in a rules file
      """
      value = Module.new do
        def self.<method>
          5
        end
      end

      after value do
        logger.info("Timer Fired")
      end
      """
    When I deploy the rules file
    Then It should not log 'Timer Fired' within 4 seconds
    Then It should log 'Timer Fired' within 3 seconds

    Examples: Works with different accessors
      | method |
      | to_f   |
      | to_i   |

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
        run { timers[:foo]&.cancel_all }
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
          timers[:foo]&.cancel_all
          logger.info("timers[:foo] is nil after cancel: #{timers[:foo].nil?}")
        end
      end
      """
    When I deploy the rule
    Then It should log 'timers[:foo] is nil before cancel: false' within 5 seconds
    And It should log 'timers[:foo] is nil after cancel: true' within 5 seconds

