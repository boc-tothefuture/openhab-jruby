Feature:  changed
  Rule languages supports item changed trigger

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

  Scenario Outline: Changed trigger for multiple items
    Given items:
      | type   | name        | label        |
      | Number | Alarm_Mode1 | Alarm Mode 1 |
      | Number | Alarm_Mode2 | Alarm Mode 2 |
    And a rule
      """
      rule 'Execute rule when either item is changed to any state' do
        changed Alarm_Mode1, Alarm_Mode2
        triggered { |item| logger.info("Multi item rule: #{item.name} changed to <state>")}
      end
      """
    When I deploy the rule
    And item "<item>" state is changed to "<state>"
    Then It should log 'Multi item rule: <item> changed to <state>' within 5 seconds
    Examples: Change items
      | item        | state |
      | Alarm_Mode1 | 3     |
      | Alarm_Mode2 | 4     |

  Scenario Outline: Changed trigger for multiple items in an array
    Given items:
      | type   | name        | label        |
      | Number | Alarm_Mode1 | Alarm Mode 1 |
      | Number | Alarm_Mode2 | Alarm Mode 2 |
    And a rule
      """
      rule 'Execute rule when either item is changed to any state' do
        changed [Alarm_Mode1, Alarm_Mode2]
        triggered { |item| logger.info("Multi item rule: #{item.name} changed to <state>")}
      end
      """
    When I deploy the rule
    And item "<item>" state is changed to "<state>"
    Then It should log 'Multi item rule: <item> changed to <state>' within 5 seconds
    Examples: Change items
      | item        | state |
      | Alarm_Mode1 | 3     |
      | Alarm_Mode2 | 4     |

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

  Scenario Outline: Item changed from one of many matching item states
    Given items:
      | type   | name       | state        |
      | Number | Alarm_Mode | <from_state> |
    And a rule
      """
      rule 'Execute rule when item is changed to specific number' do
      changed Alarm_Mode, from: [10,14]
      run { logger.info("Alarm Mode: Updated from <from_state> to <to_state>")}
      end
      """
    When I deploy the rule
    And item "Alarm_Mode" state is changed to "<to_state>"
    Then It <should> log 'Alarm Mode: Updated from <from_state> to <to_state>' within 5 seconds
    Examples:
      | from_state | to_state | should     |
      | 10         | 11       | should     |
      | 11         | 12       | should not |
      | 14         | 15       | should     |

  Scenario Outline: Changed support ranges
    Given items:
      | type   | name       | state     |
      | Number | Alarm_Mode | <initial> |
    And a deployed rule:
      """
      rule 'Execute rule with range conditions' do
        changed Alarm_Mode, <conditions>
        run { |event| logger.info("Alarm Mode: Changed from #{event.was} to #{event.state}") }
      end
      """
    When item "Alarm_Mode" state is changed to "<change>"
    Then It <should> log 'Alarm Mode: Changed from <initial> to <change>' within 5 seconds
    Examples: From range
      | initial | conditions  | change | should     |
      | 10      | from: 8..10 | 14     | should     |
      | 15      | from: 4..12 | 14     | should not |
    Examples: To range
      | initial | conditions | change | should     |
      | 4       | to:  8..10 | 9      | should     |
      | 11      | to: 4..12  | 14     | should not |
    Examples: From/To range
      | initial | conditions             | change | should     |
      | 4       | from: 2..5, to:  8..10 | 9      | should     |
      | 4       | from: 5..6, to:  8..10 | 9      | should not |
      | 4       | from: 2..5, to:  8..12 | 14     | should not |
    Examples: Endless ranges
      | initial | conditions | change | should     |
      | 4       | to: (8..)  | 9      | should     |
      | 11      | to: (15..) | 14     | should not |

  Scenario Outline: Changed supports procs
    Given items:
      | type   | name       | state     |
      | Number | Alarm_Mode | <initial> |
    And a deployed rule:
      """
      rule 'Execute rule with proc conditions' do
        changed Alarm_Mode, <conditions>
        run { |event| logger.info("Alarm Mode: Changed from #{event.was} to #{event.state}") }
      end
      """
    When item "Alarm_Mode" state is changed to "<change>"
    Then It <should> log 'Alarm Mode: Changed from <initial> to <change>' within 5 seconds
    Examples: From with lambda
      | initial | conditions                | change | should     |
      | 10      | from: ->from {from == 10} | 14     | should     |
      | 15      | from: ->from {from == 10} | 14     | should not |
    Examples: From with proc
      | initial | conditions                        | change | should     |
      | 10      | from: proc { \|from \|from == 10} | 14     | should     |
      | 15      | from: proc { \|from \|from == 10} | 14     | should not |
    Examples: To with lambda
      | initial | conditions           | change | should     |
      | 4       | to: ->to { to == 9 } | 9      | should     |
      | 11      | to: ->to { to == 9 } | 14     | should not |
    Examples: To with proc
      | initial | conditions                | change | should     |
      | 4       | to: proc {\|to\|to == 9 } | 9      | should     |
      | 11      | to: proc {\|to\|to == 9 } | 14     | should not |
    Examples: From/To with lambdas
      | initial | conditions                         | change | should     |
      | 4       | from: ->f {true}, to: ->t {true}   | 9      | should     |
      | 4       | from: ->f {false}, to: ->t {true}  | 9      | should not |
      | 4       | from: ->f {true}, to: ->t {false}  | 9      | should not |
      | 4       | from: ->f {false}, to: ->t {false} | 9      | should not |
    Examples: From/To with procs
      | initial | conditions                           | change | should     |
      | 4       | from: proc {true}, to: proc {true}   | 9      | should     |
      | 4       | from: proc {false}, to: proc {true}  | 9      | should not |
      | 4       | from: proc {true}, to: proc {false}  | 9      | should not |
      | 4       | from: proc {false}, to: proc {false} | 9      | should not |
    Examples: Mix procs with non-procs
      | initial | conditions                   | change | should     |
      | 4       | from: proc {true}, to: 8..10 | 9      | should     |
      | 4       | from: proc {true}, to: 8..10 | 14     | should not |
      | 4       | from: 4..10, to: proc {true} | 9      | should     |
      | 4       | from: 4, to: proc {true}     | 9      | should     |






