Feature: changed_duration
  Rule languages supports changed item features

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario Outline: Changed item supports duration and/or to and/or from.
    Given items:
      | type   | name       | label      | state  |
      | Number | Alarm_Mode | Alarm Mode | <from> |
    And a rule
      """
      rule 'Execute rule when item is changed to specific number for specified duration' do
        <rule>
        run { logger.info("Alarm Mode Updated")}
      end
      """
    When I deploy the rule
    And item "Alarm_Mode" state is changed to "<to>"
    And It should not log 'Alarm Mode Updated' within 9 seconds
    But If I wait 5 seconds
    Then It <should> log 'Alarm Mode Updated' within 5 seconds

    Examples: Checks multiple from and to states
      | from | to | rule                                                  | should     |
      | 8    | 14 | changed Alarm_Mode, for: 10.seconds                   | should     |
      | 8    | 14 | changed Alarm_Mode, to: 14, for: 10.seconds           | should     |
      | 8    | 10 | changed Alarm_Mode, to: 14, for: 10.seconds           | should not |
      | 8    | 14 | changed Alarm_Mode, from: 8, to: 14, for: 10.seconds  | should     |
      | 8    | 10 | changed Alarm_Mode, from: 10, to: 14, for: 10.seconds | should not |


  Scenario: Changed item has duration specified and is modified during that duration
    Given items:
      | type   | name       | label      |
      | Number | Alarm_Mode | Alarm Mode |
    And a deployed rule:
      """
      rule "Execute rule when item is changed and is modified during specified duration" do
        changed Alarm_Mode, for: 20.seconds
        triggered { |item| logger.info("Alarm Mode Updated to #{item}")}
      end
      """
    When item "Alarm_Mode" state is changed to "14"
    Then If I wait 5 seconds
    And item "Alarm_Mode" state is changed to "10"
    And It should not log 'Alarm Mode Updated to 14' within 20 seconds
    But If I wait 5 seconds
    Then It should log 'Alarm Mode Updated to 10' within 10 seconds

  Scenario: Changed item has to and duration specified and is modified during that duration
    Given items:
      | type   | name       | label      |
      | Number | Alarm_Mode | Alarm Mode |
    And a deployed rule:
      """
      rule "Execute rule when item is changed and is modified during specified duration" do
        changed Alarm_Mode, to: 14, for: 20.seconds
        triggered { |item| logger.info("Alarm Mode Updated to #{item}")}
      end
      """
    When item "Alarm_Mode" state is changed to "14"
    Then If I wait 5 seconds
    And item "Alarm_Mode" state is changed to "10"
    Then It should not log 'Alarm Mode Updated to 14' within 20 seconds
    And It should not log 'Alarm Mode Updated to 10' within 20 seconds

  Scenario Outline: Changed group items supports duration and/or to and/or from.
    Given group "Modes"
    Given items:
      | type   | name           | label          | group | state  |
      | Number | Alarm_Mode     | Alarm Mode     | Modes | 0      |
      | Number | Alarm_Two_Mode | Alarm Two Mode | Modes | <from> |
    And a deployed rule:
      """
      rule "Execute rule when group item is changed" do
        <rule>
        triggered { |item| logger.info("#{item.id} Changed")}
      end
      """
    When item "Alarm_Two_Mode" state is changed to "<to>"
    Then It should not log 'Alarm Two Mode Changed' within 7 seconds
    But If I wait 5 seconds
    Then It <should> log 'Alarm Two Mode Changed' within 5 seconds

    Examples: Checks multiple from and to states
      | from | to | rule                                                   | should     |
      | 8    | 14 | changed Modes.items, for: 10.seconds                   | should     |
      | 8    | 14 | changed Modes.items, to: 14, for: 10.seconds           | should     |
      | 8    | 10 | changed Modes.items, to: 14, for: 10.seconds           | should not |
      | 8    | 14 | changed Modes.items, from: 8, to: 14, for: 10.seconds  | should     |
      | 8    | 10 | changed Modes.items, from: 10, to: 14, for: 10.seconds | should not |

  Scenario Outline: Changed groups supports duration and/or to and/or from.
    Given groups:
      | type   | name     | function | params |
      | Switch | Switches | OR       | ON,OFF |
    Given items:
      | type   | name       | label      | group    | state  |
      | Switch | Switch_One | Switch One | Switches | OFF    |
      | Switch | Switch_Two | Switch Two | Switches | <from> |
    And a deployed rule:
      """
      rule "Execute rule when group is changed" do
        <rule>
        triggered { |item| logger.info("#{item.id} Changed")}
      end
      """
    When item "Switch_Two" state is changed to "<to>"
    Then It should not log 'Switches Changed' within 7 seconds
    But If I wait 5 seconds
    Then It <should> log 'Switches Changed' within 5 seconds

    Examples: Checks multiple from and to states
      | from | to  | rule                                                 | should     |
      | OFF  | ON  | changed Switches, for: 10.seconds                    | should     |
      | OFF  | ON  | changed Switches, to: ON, for: 10.seconds            | should     |
      | ON   | OFF | changed Switches, to: ON, for: 10.seconds            | should not |
      | OFF  | ON  | changed Switches, from: OFF, to: ON, for: 10.seconds | should     |
      | OFF  | ON  | changed Switches, from: ON, to: ON, for: 10.seconds  | should not |

  Scenario: Multiple changed with duration triggers
    Given items:
      | type   | name       | label      | group | state |
      | Switch | Switch_One | Switch One |       | OFF   |
      | Switch | Switch_Two | Switch Two |       | OFF   |
    And a rule:
      """
      rule 'A rule with multiple changed duration triggers' do
        changed Switch_One, to: ON, for: 4.seconds
        changed Switch_Two, to: ON, for: 8.seconds
        triggered do |item|
          logger.info("#{item.name} changed")
        end
      end
      """
    When I deploy the rule
    And item "Switch_One" state is changed to "ON"
    And item "Switch_Two" state is changed to "ON"
    Then It should not log "Switch_One changed" within 2 seconds
    And It should not log "Switch_Two changed" within 5 seconds
    And It should log "Switch_One changed" within 6 seconds
    And It should log "Switch_Two changed" within 10 seconds

  Scenario Outline: Changed with duration triggers with guard
    Given items:
      | type   | name       | label      | group | state |
      | Switch | Switch_One | Switch One |       | OFF   |
    And a rule:
      """
      rule 'A rule with a changed duration and a condition' do
        changed Switch_One, to: ON, for: 1.second
        only_if { <condition> }
        triggered { |item| logger.info("Rule #{item.name} changed") }
      end
      """
    When I deploy the rule
    And item "Switch_One" state is changed to "ON"
    Then It <should> log "Rule Switch_One changed" within 5 seconds
    Examples:
      | condition | should     |
      | false     | should not |
      | true      | should     |

  Scenario: Changed duration with StringItem
    Given items:
      | type   | name       | label      | state |
      | String | String_One | String One | ONE   |
    And a rule:
      """
    rule 'Changed String' do
      changed String_One, to: 'TWO', for: 2.seconds
      triggered do |item|
        logger.info("Changed rule: #{item.name} changed")
      end
    end
      """
    When I deploy the rule
    And item "String_One" state is changed to "TWO"
    Then It should log "Changed rule: String_One changed" within 5 seconds
