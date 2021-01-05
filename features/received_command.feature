Feature:  Rule languages supports changed item features

  Background:
    Given Clean OpenHAB with latest Ruby Libraries
    And group "AlarmModes"
    And items:
      | type   | name             | group      | state |
      | Number | Alarm_Mode       | AlarmModes | 7     |
      | Number | Alarm_Mode_Other | AlarmModes | 7     |

  Scenario: Rule supports received_command
    Given a deployed rule:
      """
      rule 'Execute rule when item received command' do
        received_command Alarm_Mode
        run { |event| logger.info("Item received command: #{event.command}" ) }
      end
      """
    When item "Alarm_Mode" state is changed to "7"
    Then It should log 'Item received command: 7' within 5 seconds

  Scenario Outline: Rule supports received_command with specific values
    Given a deployed rule:
      """
      rule 'Execute rule when item receives specific command' do
        received_command Alarm_Mode, command: 7
        run { |event| logger.info("Item received command: #{event.command}" ) }
      end
      """
    When item "Alarm_Mode" state is changed to "<state>"
    Then It <log> log 'Item received command: <state>' within 5 seconds
    Examples:
      | state | log        |
      | 7     | should     |
      | 14    | should not |

  Scenario Outline: Rule supports received_command to one of many matching values
    Given a deployed rule:
      """
      rule 'Execute rule when item receives one of many specific commands' do
        received_command Alarm_Mode, commands: [7,14]
        run { |event| logger.info("Item received command: #{event.command}" ) }
      end
      """
    When item "Alarm_Mode" state is changed to "<state>"
    Then It <log> log 'Item received command: <state>' within 5 seconds
    Examples:
      | state | log        |
      | 7     | should     |
      | 14    | should     |
      | 10    | should not |

  Scenario: Rules support group receives command
    Given a deployed rule:
      """
      rule 'Execute rule when group receives a specific command' do
        received_command AlarmModes
        triggered { |item| logger.info("Group #{item.id} received command")}
      end
      """
    When item "AlarmModes" state is changed to "7"
    Then It should log 'Group AlarmModes received command' within 5 seconds

  Scenario: Rules support group members received command
    Given a deployed rule:
      """
      rule 'Execute rule when member of group receives any command' do
        received_command AlarmModes.items
        triggered { |item| logger.info("Group item #{item.id} received command")}
      end
      """
    When item "AlarmModes" state is changed to "7"
    Then It should log 'Group item Alarm_Mode received command' within 5 seconds

  Scenario Outline: Rules support group members received command for specific commands
    Given a deployed rule:
      """
      rule 'Execute rule when member of group is changed to one of many states' do
        received_command AlarmModes.items, commands: [7,14]
        triggered { |item| logger.info("Group item #{item.id} received command")}
      end
      """
    When item "AlarmModes" state is changed to "<state>"
    Then It <log> log 'Group item Alarm_Mode received command' within 5 seconds
    Examples:
      | state | log        |
      | 7     | should     |
      | 14    | should     |
      | 10    | should not |


