Feature:  updated
  Rule languages supports item update trigger

  Background:
    Given Clean OpenHAB with latest Ruby Libraries
    And group "AlarmModes"
    And items:
      | type   | name             | group      | state |
      | Number | Alarm_Mode       | AlarmModes | 7     |
      | Number | Alarm_Mode_Other | AlarmModes | 7     |

  Scenario: Item updated to any value
    Given a deployed rule:
      """
      rule 'Execute rule when item is updated to any value' do
        updated Alarm_Mode
        run { logger.info("Alarm Mode Updated") }
      end
      """
    When update state for item "Alarm_Mode" to "7"
    Then It should log 'Alarm Mode Updated' within 5 seconds

  Scenario Outline: Item updated with specified value
    Given a deployed rule:
      """
      rule 'Execute rule when item is updated to specific number' do
        updated Alarm_Mode, to: 7
        run { logger.info("Alarm Mode Updated") }
      end
      """
    When update state for item "Alarm_Mode" to "<update>"
    Then It <log> log 'Alarm Mode Updated' within 5 seconds
    Examples:
      | update | log        |
      | 7      | should     |
      | 14     | should not |

  Scenario Outline: Item updated to one of many matching values
    Given a deployed rule:
      """
      rule 'Execute rule when item is updated to one of many specific states' do
        updated Alarm_Mode, to: [7,14]
        run { logger.info("Alarm Mode Updated")}
      end
      """
    When update state for item "Alarm_Mode" to "<update>"
    Then It <log> log 'Alarm Mode Updated' within 5 seconds
    Examples:
      | update | log        |
      | 7      | should     |
      | 14     | should     |
      | 10     | should not |

  Scenario: group updated to any state
    Given a deployed rule:
      """
      rule 'Execute rule when group is updated to any state' do
        updated AlarmModes
        triggered { |item| logger.info("Group #{item.id} updated")}
      end
      """
    When update state for item "AlarmModes" to "7"
    Then It should log 'Group AlarmModes updated' within 5 seconds

  Scenario: Updated works with group members
    Given a deployed rule:
      """
      rule 'Execute rule when member of group is changed to any state' do
        updated AlarmModes.members
        triggered { |item| logger.info("Group item #{item.id} updated")}
      end
      """
    When update state for item "Alarm_Mode" to "7"
    Then It should log 'Group item Alarm_Mode updated' within 5 seconds

  Scenario Outline: Updated works with group members to specific states
    Given a deployed rule:
      """
      rule 'Execute rule when member of group is changed to one of many states' do
        updated AlarmModes.members, to: [7,14]
        triggered { |item| logger.info("Group item #{item.id} updated")}
      end
      """
    When update state for item "Alarm_Mode" to "<update>"
    Then It <log> log 'Group item Alarm_Mode updated' within 5 seconds
    Examples:
      | update | log        |
      | 7      | should     |
      | 14     | should     |
      | 10     | should not |

  Scenario Outline: Updated support ranges
    Given items:
      | type   | name       | state     |
      | Number | Alarm_Mode | <initial> |
    And a deployed rule:
      """
      rule 'Execute rule with range conditions' do
        updated Alarm_Mode, <conditions>
        run { |event| logger.info("Alarm Mode: Updated to #{event.state}") }
      end
      """
    When item "Alarm_Mode" state is changed to "<change>"
    Then It <should> log 'Alarm Mode: Updated to <change>' within 5 seconds
    Examples: To range
      | initial | conditions | change | should     |
      | 4       | to:  8..10 | 9      | should     |
      | 11      | to: 4..12  | 14     | should not |


  Scenario Outline: Updated support procs
    Given items:
      | type   | name       | state     |
      | Number | Alarm_Mode | <initial> |
    And a deployed rule:
      """
      rule 'Execute rule with proc conditions' do
        updated Alarm_Mode, <conditions>
        run { |event| logger.info("Alarm Mode: Updated to #{event.state}") }
      end
      """
    When item "Alarm_Mode" state is changed to "<change>"
    Then It <should> log 'Alarm Mode: Updated to <change>' within 5 seconds
    Examples: To with lambda
      | initial | conditions                     | change | should     |
      | 4       | to: ->t { (8..10).include? t } | 9      | should     |
      | 11      | to: ->t { (4..12).include? t } | 14     | should not |
    Examples: To with proc
      | initial | conditions                           | change | should     |
      | 4       | to: proc { \|t\|(8..10).include? t } | 9      | should     |
      | 11      | to: proc { \|t\|(4..12).include? t } | 14     | should not |


