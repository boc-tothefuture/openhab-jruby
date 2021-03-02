Feature:  changed
  Rule languages supports changed item features

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario: Item changed to matching item state
    Given items:
      | type   | name       | label      |
      | Number | Alarm_Mode | Alarm Mode |
    And a rule
      """
      rule 'Execute rule when item is changed to specific number' do
      changed Alarm_Mode, to: 14
      run { logger.info("Alarm Mode Updated")}
      end
      """
    When I deploy the rule
    And item "Alarm_Mode" state is changed to "14"
    Then It should log 'Alarm Mode Updated' within 5 seconds

  Scenario: Item changed to one of many matching item states
    Given items:
      | type   | name       | label      |
      | Number | Alarm_Mode | Alarm Mode |
    And a rule
      """
      rule 'Execute rule when item is changed to specific number' do
      changed Alarm_Mode, to: [10,14]
      run { logger.info("Alarm Mode Updated")}
      end
      """
    When I deploy the rule
    And item "Alarm_Mode" state is changed to "10"
    Then It should log 'Alarm Mode Updated' within 5 seconds

  Scenario: Item changed to state not in set of matching states
    Given items:
      | type   | name       | label      |
      | Number | Alarm_Mode | Alarm Mode |
    And a rule
      """
      rule 'Execute rule when item is changed to specific number' do
      changed Alarm_Mode, to: [10,14]
      run { logger.info("Alarm Mode Updated")}
      end
      """
    When I deploy the rule
    And item "Alarm_Mode" state is changed to "7"
    Then It should not log 'Alarm Mode Updated' within 5 seconds


  Scenario: Item changed to any State
    Given items:
      | type   | name       | label      |
      | Number | Alarm_Mode | Alarm Mode |
    And a rule
      """
      rule 'Execute rule when item is changed to any state' do
        changed Alarm_Mode
        run { logger.info("Alarm Mode Updated")}
      end
      """
    When I deploy the rule
    And item "Alarm_Mode" state is changed to "7"
    Then It should log 'Alarm Mode Updated' within 5 seconds

  Scenario: Changed works with groups
    Given groups:
      | type   | name     | function | params |
      | Switch | Switches | OR       | ON,OFF |
    And items:
      | type   | name    | label             | state | group    |
      | Switch | Switch1 | Switch Number One | OFF   | Switches |
    And a deployed rule:
      """
      rule 'Execute rule when item is changed to any state' do
        changed Switches
        triggered { |item| logger.info("Group #{item.id} changed")}
      end
      """
    When item "Switch1" state is changed to "ON"
    Then It should log 'Group Switches changed' within 5 seconds

  Scenario: Changed works with group members
    Given group "Switches"
    And items:
      | type   | name    | label             | state | group    |
      | Switch | Switch1 | Switch Number One | OFF   | Switches |
    And a deployed rule:
      """
      rule 'Execute rule when item is changed to any state' do
        changed Switches.members
        triggered { |item| logger.info("Switch #{item.id} changed")}
      end
      """
    When item "Switch1" state is changed to "ON"
    Then It should log 'Switch Switch Number One changed' within 5 seconds

  Scenario: Changed trigger operates newly added items in groups
    Given group "Switches"
    And items:
      | type   | name    | label             | state | group    |
      | Switch | Switch1 | Switch Number One | OFF   | Switches |
    And a deployed rule:
      """
      rule 'Execute rule when item is changed to any state' do
        changed Switches.members
        triggered { |item| logger.info("Switch #{item.id} changed")}
      end
      """
    When I add items:
      | type   | name    | label             | state | group    |
      | Switch | Switch2 | Switch Number Two | OFF   | Switches |
    And item "Switch2" state is changed to "ON"
    Then It should log 'Switch Switch Number Two changed' within 5 seconds

  Scenario Outline: Item changed fires for appropriate state changes
    Given items:
      | type   | name       | state           |
      | Switch | TestSwitch | <initial_state> |
    And a rule
      """
      rule 'Execute rule when item is changed from one state to another' do
        changed TestSwitch
        run { logger.info("Switch Changed")}
      end
      """
    When I deploy the rule
    And item "TestSwitch" state is changed to "<state>"
    Then It <should> log 'Switch Changed' within 5 seconds
    Examples: Checks various initial and final states
      | initial_state | state | should     |
      | OFF           | OFF   | should not |
      | OFF           | ON    | should     |
      | ON            | ON    | should not |
      | ON            | OFF   | should     |

  Scenario: GroupMembers are separated from items in triggers
    Given groups:
      | type    | name     |
      | Switch  | Switches |
      | Contact | Contacts |

    And items:
      | type    | name     | group    |
      | Switch  | Switch1  | Switches |
      | Switch  | Switch2  | Switches |
      | Switch  | Switch3  |          |
      | Contact | Contact1 | Contacts |
      | Contact | Contact2 | Contacts |

    And a deployed rule:
      """
      rule 'Nested groups' do
        changed Switches.members, [[Contacts.members], Switch3]
        triggered { |item| logger.info("#{item.id} triggered the rule") }
      end
      """
    When I add items:
      | type    | name     | group    |
      | Contact | Contact3 | Contacts |
    And item "<item>" state is changed to "<state>"
    Then It should log "<item> triggered the rule" within 2 seconds
    Examples:
        | item     | state |
        | Switch1  | ON    |
        | Switch3  | ON    |
        | Contact3 | OPEN  |
