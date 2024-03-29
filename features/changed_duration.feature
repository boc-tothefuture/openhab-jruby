Feature: changed_duration
  Rule languages supports changed item features

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario Outline: Changed item supports duration and/or to and/or from.
    Given items:
      | type   | name        | label       | state  |
      | Number | Alarm_Mode  | Alarm Mode  | <from> |
      | Number | Alarm_Delay | Alarm Delay | 5      |
    And a rule
      """
      rule 'Execute rule when item is changed to specific number for specified duration' do
        <trigger>, for: <delay>
        run { logger.info("Alarm Mode Updated")}
      end
      """
    When I deploy the rule
    And item "Alarm_Mode" state is changed to "<to>"
    And It should not log 'Alarm Mode Updated' within 4 seconds
    Then It <should> log 'Alarm Mode Updated' within 5 seconds

    Examples: Checks multiple from and to states
      | from | to | trigger                                         | delay       | should     |
      | 8    | 14 | changed Alarm_Mode                              | 5.seconds   | should     |
      | 8    | 14 | changed Alarm_Mode                              | Alarm_Delay | should     |
      | 8    | 14 | changed Alarm_Mode, to: 14                      | 5.seconds   | should     |
      | 8    | 10 | changed Alarm_Mode, to: 14                      | 5.seconds   | should not |
      | 8    | 14 | changed Alarm_Mode, from: 8, to: 14             | 5.seconds   | should     |
      | 8    | 10 | changed Alarm_Mode, from: 10, to: 14            | 5.seconds   | should not |
      | 8    | 14 | changed Alarm_Mode, to: [10, 14]                | 5.seconds   | should     |
      | 8    | 14 | changed Alarm_Mode, from: [8, 10], to: 14       | 5.seconds   | should     |
      | 8    | 14 | changed Alarm_Mode, from: [8, 10], to: [11, 14] | 5.seconds   | should     |
      | 8    | 12 | changed Alarm_Mode, from: [8, 10], to: [11, 14] | 5.seconds   | should not |
      | 8    | 14 | changed Alarm_Mode, from: [9, 10], to: [11, 14] | 5.seconds   | should not |

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
    Then It should log 'Alarm Mode Updated to 10' within 10 seconds

  Scenario: Changed item has to and duration specified and is modified during that duration
    Given items:
      | type   | name       | label      |
      | Number | Alarm_Mode | Alarm Mode |
    And a deployed rule:
      """
      rule "Execute rule when item is changed and is modified during specified duration" do
        changed Alarm_Mode, to: 14, for: 10.seconds
        triggered { |item| logger.info("Alarm Mode Updated to #{item}")}
      end
      """
    When item "Alarm_Mode" state is changed to "14"
    Then If I wait 5 seconds
    And item "Alarm_Mode" state is changed to "10"
    Then It should not log 'Alarm Mode Updated to' within 20 seconds

  Scenario Outline: Changed group items supports duration and/or to and/or from.
    Given group "Modes"
    Given items:
      | type   | name           | label          | group | state  |
      | Number | Alarm_Mode     | Alarm Mode     | Modes | 0      |
      | Number | Alarm_Two_Mode | Alarm Two Mode | Modes | <from> |
    And a deployed rule:
      """
      rule "Execute rule when group item is changed" do
        <trigger>, for: 5.seconds
        triggered { |item| logger.info("#{item.id} Changed")}
      end
      """
    When item "Alarm_Two_Mode" state is changed to "<to>"
    Then It should not log 'Alarm Two Mode Changed' within 4 seconds
    But If I wait 1 seconds
    Then It <should> log 'Alarm Two Mode Changed' within 5 seconds

    Examples: Checks multiple from and to states
      | from | to | trigger                                 | should     |
      | 8    | 14 | changed Modes.members                   | should     |
      | 8    | 14 | changed Modes.members, to: 14           | should     |
      | 8    | 10 | changed Modes.members, to: 14           | should not |
      | 8    | 14 | changed Modes.members, from: 8, to: 14  | should     |
      | 8    | 10 | changed Modes.members, from: 10, to: 14 | should not |

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
        <rule>, for: 5.seconds
        triggered { |item| logger.info("#{item.id} Changed")}
      end
      """
    When item "Switch_Two" state is changed to "<to>"
    Then It should not log 'Switches Changed' within 4 seconds
    But If I wait 1 seconds
    Then It <should> log 'Switches Changed' within 5 seconds

    Examples: Checks multiple from and to states
      | from | to  | rule                                | should     |
      | OFF  | ON  | changed Switches                    | should     |
      | OFF  | ON  | changed Switches, to: ON            | should     |
      | ON   | OFF | changed Switches, to: ON            | should not |
      | OFF  | ON  | changed Switches, from: OFF, to: ON | should     |
      | OFF  | ON  | changed Switches, from: ON, to: ON  | should not |

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

  Scenario: Timers in changed duration are cancelled if the script is removed
    Given items:
      | type   | name       | label      | state |
      | String | String_One | String One | ONE   |
    And a rule:
      """
      rule 'Changed String' do
        changed String_One, to: 'TWO', for: 5.seconds
        triggered do |item|
          logger.info("Trigger Delay Fired")
        end
      end
      """
    When I deploy the rules file
    And item "String_One" state is changed to "TWO"
    When I wait 2 seconds
    And I remove the rules file
    Then It should not log 'Trigger Delay Fired' within 10 seconds

  Scenario Outline: Changed duration support ranges
    Given items:
      | type   | name       | state     |
      | Number | Alarm_Mode | <initial> |
    And a deployed rule:
      """
      rule 'Execute rule with range conditions' do
        changed Alarm_Mode, <conditions>, for: 5.seconds
        run { |event| logger.info("Alarm Mode: Changed from #{event.was} to #{event.state}") }
      end
      """
    When item "Alarm_Mode" state is changed to "<change>"
    Then It should not log 'Alarm Mode: Changed from <initial> to <change>' within 4 seconds
    But If I wait 1 seconds
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

  Scenario Outline: Changed duration support procs
    Given items:
      | type   | name       | state     |
      | Number | Alarm_Mode | <initial> |
    And a deployed rule:
      """
      rule 'Execute rule with range conditions' do
        changed Alarm_Mode, <conditions>, for: 5.seconds
        run { |event| logger.info("Alarm Mode: Changed from #{event.was} to #{event.state}") }
      end
      """
    When item "Alarm_Mode" state is changed to "<change>"
    Then It should not log 'Alarm Mode: Changed from <initial> to <change>' within 4 seconds
    But If I wait 1 seconds
    Then It <should> log 'Alarm Mode: Changed from <initial> to <change>' within 5 seconds
    Examples: From lambda
      | initial | conditions            | change | should     |
      | 10      | from: ->f { f == 10 } | 14     | should     |
      | 15      | from: ->f { f == 10 } | 14     | should not |
    Examples: To lambda
      | initial | conditions         | change | should     |
      | 4       | to: ->t { t == 9 } | 9      | should     |
      | 11      | to: ->t { t == 13} | 14     | should not |
    Examples: From/To lambda
      | initial | conditions                                | change | should     |
      | 4       | from: ->f { f == 4 }, to: ->t { t == 9 }  | 9      | should     |
      | 4       | from: ->f { f == 4 }, to: ->t { t == 8 }  | 9      | should not |
      | 4       | from: ->f { f == 94 }, to: ->t { t == 9 } | 9      | should not |
