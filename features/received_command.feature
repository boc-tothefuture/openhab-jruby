Feature:  received_command
  Rule languages supports changed item features

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

  Scenario Outline: Rule supports helper predicates for named commands
    Given items:
      | type        | name     |
      | <item_type> | TestItem |
    And a deployed rule:
      """
      rule 'Execute rule when item received command' do
        received_command TestItem
        run do |event|
          predicates = %i[refresh? on? off? increase? decrease? up? down? stop? move? play? pause? rewind? fast_forward? next? previous?]

          predicate_to_command_map = predicates.map {|pred| [pred, pred[0..-2].upcase] }.to_h.merge(fast_forward?: 'FASTFORWARD')

          command = "<command>"
          predicate = predicate_to_command_map.key(command)

          logger.info("Item received <command>: #{event.send(predicate)}")

          other_results = predicates.grep_v(predicate).select { |other_pred| event.send(other_pred) }
          logger.info("Other predicates matched: #{other_results.any?} #{other_results}")
        end
      end
      """
    When item "TestItem" state is changed to "<command>"
    Then It should log 'Item received <command>: true' within 5 seconds
    And It should log 'Other predicates matched: false' within 5 seconds
    Examples:
      | item_type     | command     |
      | Switch        | REFRESH     |
      | Switch        | ON          |
      | Switch        | OFF         |
      | Dimmer        | INCREASE    |
      | Dimmer        | DECREASE    |
      | Rollershutter | UP          |
      | Rollershutter | DOWN        |
      | Rollershutter | STOP        |
      | Rollershutter | MOVE        |
      | Player        | PLAY        |
      | Player        | PAUSE       |
      | Player        | REWIND      |
      | Player        | FASTFORWARD |
      | Player        | NEXT        |
      | Player        | PREVIOUS    |

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
        received_command AlarmModes.members
        triggered { |item| logger.info("Group item #{item.id} received command")}
      end
      """
    When item "AlarmModes" state is changed to "7"
    Then It should log 'Group item Alarm_Mode received command' within 5 seconds

  Scenario Outline: Rules support group members received command for specific commands
    Given a deployed rule:
      """
      rule 'Execute rule when member of group is changed to one of many states' do
        received_command AlarmModes.members, commands: [7,14]
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


  Scenario Outline: event.command for Color item can be compared to accepted command types
    Given items:
      | type  | name  |
      | Color | Item1 |
    And a rule
      """
      hsb000 = HSBType.new(0,0,0) # Doing this because https://github.com/boc-tothefuture/openhab-jruby/issues/348
      rule 'handle command' do
        received_command Item1
        run do |event|
          logger.info("We sent a command <command>")
          logger.info("event.command.class: #{event.command.class}")
          log = case event.command
                when <cond1> then 'cond1'
                when <cond2> then 'cond2'
                when <cond3> then 'cond3'
                else 'cond-else'
                end
          logger.info("case match: #{log}")
        end
      end

      Item1 << <command>
      """
    When I deploy the rule
    Then It should log 'case match: <log>' within 5 seconds
    Examples:
      | command  | cond1       | cond2                    | cond3    | log   |
      | ON       | ON          | 1..100                   | INCREASE | cond1 |
      | ON       | 0..99,100   | OFF                      | ON       | cond3 |
      | OFF      | OFF         | INCREASE,DECREASE        | 0        | cond1 |
      | OFF      | 1..100      | 0                        | OFF      | cond3 |
      | INCREASE | ON,DECREASE | 0..100                   | INCREASE | cond3 |
      | DECREASE | OFF         | 0,INCREASE               | DECREASE | cond3 |
      | 0        | OFF         | DECREASE                 | 0        | cond3 |
      | 0        | ON          | DECREASE                 | 0..50    | cond3 |
      | 50       | ON          | INCREASE                 | 50       | cond3 |
      | 100      | ON          | 0..99                    | 100      | cond3 |
      | '0,0,0'  | '1,2,3'     | ON,OFF,DECREASE,INCREASE | hsb000   | cond3 |

  Scenario Outline: event.command for Player item can be compared to accepted command types
    Given items:
      | type   | name  |
      | Player | Item1 |
    And a rule
      """
      rule 'handle command' do
        received_command Item1
        run do |event|
          logger.info('We sent a command <command>')
          logger.info("event.command.class: #{event.command.class}")
          log = case event.command
                when <cond1> then 'cond1'
                when <cond2> then 'cond2'
                when <cond3> then 'cond3'
                else 'cond-else'
                end
          logger.info("case match: #{log}")
        end
      end
      """
    When I deploy the rule
    And item "Item1" state is changed to "<command>"
    Then It should log 'case match: <log>' within 5 seconds
    Examples:
      | command | cond1 | cond2                            | cond3 | log   |
      | PLAY    | PLAY  | 1..100                           | ON    | cond1 |
      | PLAY    | PAUSE | NEXT,PREVIOUS,REWIND,FASTFORWARD | PLAY  | cond3 |

  Scenario Outline: event.command for Rollershutter item can be compared to accepted command types
    Given items:
      | type          | name  |
      | Rollershutter | Item1 |
    And a rule
      """
      rule 'handle command' do
        received_command Item1
        run do |event|
          logger.info('We sent a command <command>')
          logger.info("event.command.class: #{event.command.class}")
          log = case event.command
                when <cond1> then 'cond1'
                when <cond2> then 'cond2'
                when <cond3> then 'cond3'
                else 'cond-else'
                end
          logger.info("case match: #{log}")
        end
      end
      """
    When I deploy the rule
    And item "Item1" state is changed to "<command>"
    Then It should log 'case match: <log>' within 5 seconds
    Examples:
      | command | cond1     | cond2                        | cond3   | log       |
      | UP      | 0         | 1..100                       | DOWN,UP | cond3     |
      | UP      | 100       | STOP,MOVE,'UP'               | UP      | cond3     |
      | DOWN    | UP        | 0..100                       | DOWN    | cond3     |
      | DOWN    | 0..100    | INCREASE,DECREASE,PLAY,PAUSE | UP      | cond-else |
      | STOP    | STOP      | MOVE                         | 0       | cond1     |
      | MOVE    | STOP      | UP,DOWN                      | MOVE    | cond3     |
      | 0       | STOP,MOVE | UP,DOWN                      | 0       | cond3     |
      | 100     | STOP,MOVE | 100                          | UP      | cond2     |


  Scenario Outline: received command support ranges
    Given items:
      | type   | name       | state     |
      | Number | Alarm_Mode | <initial> |
    And a deployed rule:
      """
      rule 'Execute rule with range conditions' do
        received_command Alarm_Mode, <conditions>
        run { |event| logger.info("Alarm Mode: Received command #{event.command}") }
      end
      """
    When item "Alarm_Mode" state is changed to "<change>"
    Then It <should> log 'Alarm Mode: Received command <change>' within 5 seconds
    Examples: With range
      | initial | conditions       | change | should     |
      | 4       | commands:  8..10 | 9      | should     |
      | 11      | commands: 4..12  | 14     | should not |


  Scenario Outline: Received command supports procs
    Given items:
      | type   | name       | state     |
      | Number | Alarm_Mode | <initial> |
    And a deployed rule:
      """
      rule 'Execute rule with proc conditions' do
        received_command Alarm_Mode, <conditions>
        run { |event| logger.info("Alarm Mode: Received command #{event.command}") }
      end
      """
    When item "Alarm_Mode" state is changed to "<change>"
    Then It <should> log 'Alarm Mode: Received command <change>' within 5 seconds
    Examples: With lambda
      | initial | conditions                          | change | should     |
      | 4       | command: ->t { (8..10).include? t } | 9      | should     |
      | 11      | command: ->t { (4..12).include? t } | 14     | should not |
    Examples: With proc
      | initial | conditions                                | change | should     |
      | 4       | command: proc { \|t\|(8..10).include? t } | 9      | should     |
      | 11      | command: proc { \|t\|(4..12).include? t } | 14     | should not |


