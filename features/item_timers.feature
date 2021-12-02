Feature:  item_timers
  Openhab Item timers

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario: Items have implicit timers when accepting commands
   Given items:
    | type   | name       | label      | state | 
    | Number | Alarm_Mode | Alarm Mode | 0     |
   And code in a rules file
      """
      Alarm_Mode.command(70, for: 5.seconds)
      """
    When I deploy the rule
    Then "Alarm_Mode" should be in state "70" within 3 seconds
    And If I wait 3 seconds
    Then "Alarm_Mode" should be in state "0" within 3 seconds

  Scenario: Items can set expire state
   Given items:
    | type   | name       | label      | state | 
    | Number | Alarm_Mode | Alarm Mode | 0     |
   And code in a rules file
      """
      Alarm_Mode.command(70, for: 5.seconds, on_expire: 9)
      """
    When I deploy the rule
    Then "Alarm_Mode" should be in state "70" within 3 seconds
    And If I wait 3 seconds
    Then "Alarm_Mode" should be in state "9" within 3 seconds

  Scenario: Implicit item timers are reentrant
   Given items:
    | type   | name       | state | 
    | String | Alarm_Mode | foo   |
    | Switch | Switch1    | OFF   |
   And code in a rules file
      """
      rule 'Reentrant implicit timer' do
       changed Switch1, to: ON
       run { Alarm_Mode.command('bar', for: 5.seconds) }
       on_start
      end
      """
    When I deploy the rule
    Then "Alarm_Mode" should be in state "bar" within 3 seconds
    But If I send command "ON" to item "Switch1"
    And "Alarm_Mode" should stay in state "bar" for 4 seconds
    But If I wait 3 seconds
    Then "Alarm_Mode" should be in state "foo" within 5 seconds

  Scenario Outline: ON/OFF default expire to their inverse
   Given items:
    | type   | name    | state             | 
    | Switch | Switch1 | <initial_state>   |
   And code in a rules file
      """
      Switch1.command(<timed_set>, for: 5.seconds)
      """
    When I deploy the rule
    Then "Switch1" should be in state "<timed_set>" within 3 seconds
    But If I wait 7 seconds
    Then "Switch1" should be in state "<final_state>" within 3 seconds
    Examples:
      | initial_state | timed_set| final_state |
      | ON            | ON       | OFF         |
      | OFF           | OFF      | ON          |
      | OFF           | ON       | OFF         |
      | ON            | OFF      | ON          |


  Scenario Outline: Dynamically defined commands (on,off,etc) have implicit timers
   Given items:
    | type   | name    | state                | 
    | <type> | Item1   | <initial_state>      |
   And code in a rules file
      """
      Item1.<command> for: 5.seconds
      """
   When I deploy the rule
   Then "Item1" should be in state "<timed_state>" within 3 seconds
   But If I wait 5 seconds
   Then "Item1" should be in state "<initial_state>" within 3 seconds
   Examples:
      | type     | initial_state | command | timed_state | 
      | Switch   | OFF           | on      | ON          |
      | Switch   | ON            | off     | OFF         |
      | Player   | PLAY          | pause   | PAUSE       |


  Scenario: Implicit command timers can accept expire blocks
   Given items:
    | type   | name    | state    | 
    | Switch | Switch1 | OFF      |
   And code in a rules file
      """
      Switch1.command(ON, for: 5.seconds) do |timed_command|
        logger.info("Expired: #{timed_command.expired?}") 
      end
      """
   When I deploy the rule
   Then It should not log 'Expired' within 3 seconds
   But If I wait 2 seconds
   Then It should log 'Expired: true' within 3 seconds


   Scenario: Implicit timers are canceled when item state changes before timer expires
   Given items:
    | type   | name    | state    | 
    | Switch | Switch1 | OFF      |
   And code in a rules file
    """
    Switch1.on for: 5.seconds, on_expire: ON
    """
   When I deploy the rule
   Then "Switch1" should be in state "ON" within 3 seconds
   But If I send command "OFF" to item "Switch1"
   Then "Switch1" should stay in state "OFF" for 8 seconds


   Scenario: Supplied blocks are called when timers are cancelled
   Given items:
    | type   | name    | state    | 
    | Switch | Switch1 | OFF      |
   And code in a rules file
    """
    Switch1.on for: 5.seconds do |event|
      logger.info("Timed Command Canceled: #{event.canceled?}")
    end
    """
   When I deploy the rule
   Then If I wait 2 seconds 
   And If I send command "OFF" to item "Switch1"
   Then It should log 'Timed Command Canceled: true' within 3 seconds


   Scenario Outline: Implicit timers work with ensure
   Given items:
    | type   | name    | state           | 
    | Switch | Switch1 | <initial_state> |
   And code in a rules file
    """
    Switch1.ensure.on for: 5.seconds
    """
   When I deploy the rule
   Then "Switch1" should be in state "ON" within 3 seconds
   But If I wait 5 seconds
   Then "Switch1" should be in state "OFF" within 5 seconds
   Examples:
      | initial_state | 
      |  OFF          | 
      |  ON           | 

   Scenario: Implicit timers can have duration updated 
   Given items:
    | type   | name    | state  | 
    | Switch | Switch1 | OFF    |
   And code in a rules file
    """
    Switch1.ensure.on for: 3.seconds
    Switch1.ensure.on for: 10.seconds
    """
   When I deploy the rule
   Then "Switch1" should be in state "ON" within 3 seconds
   And "Switch1" should stay in state "ON" for 6 seconds
   Then "Switch1" should be in state "OFF" within 6 seconds

