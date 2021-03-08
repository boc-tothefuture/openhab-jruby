Feature: rollershutter_item
  Rollershutter Items are supported

  Background:
    Given Clean OpenHAB with latest Ruby Libraries
    And group "Rollershutters"
    And items:
      | type          | name      | label      | group          |
      | Rollershutter | RollerOne | Roller One | Rollershutters |
      | Rollershutter | RollerTwo | Roller Two | Rollershutters |

  Scenario: Sending command using PercentType work
    Given item "RollerOne" state is changed to "<initial>"
    And item "RollerTwo" state is changed to "0"
    And code in a rules file
      """
      java_import Java::OrgOpenhabCoreLibraryTypes::DecimalType

      RollerOne << <command>
      """
    When I deploy the rules file
    Then "RollerOne" should be in state "<final>" within 5 seconds
    Examples:
      | initial | command             | final |
      | 50      | 70                  | 70    |
      | 50      | RollerTwo           | 0     |
      | 50      | DecimalType.new(10) | 10    |

  Scenario: Command methods work
    Given item "RollerOne" state is changed to "<initial>"
    And code in a rules file
      """
      RollerOne.<method>
      """
    When I deploy the rules file
    Then "RollerOne" should be in state "<final>" within 5 seconds
    Examples:
      | initial | method | final |
      | 50      | up     | 0     |
      | 50      | down   | 100   |

  Scenario: Stop/Move commands are processed
    Given item "RollerOne" state is changed to "<initial>"
    And code in a rules file
      """
      RollerOne.<method>
      """
    When I deploy the rules file
    Then It should log 'Command <command>' within 5 seconds
    Examples:
      | initial | method | command |
      | 50      | stop   | STOP    |
      | 50      | move   | MOVE    |

  Scenario: up? and down? methods work
    Given item "RollerOne" state is changed to "<initial>"
    And code in a rules file
      """
      logger.info(RollerOne.<method>)
      """
    When I deploy the rules file
    Then It should log "<result>" within 5 seconds
    Examples:
      | initial | method | result |
      | 0       | up?    | true   |
      | 0       | down?  | false  |
      | 100     | up?    | false  |
      | 100     | down?  | true   |
      | 50      | up?    | false  |
      | 50      | down?  | false  |

  Scenario: Math operations work
    Given item "RollerOne" state is changed to "30"
    And code in a rules file
      """
      logger.info(<left_operand> <operator> <right_operand>)
      """
    When I deploy the rules file
    Then It should log "<result>" within 5 seconds
    Examples:
      | left_operand | operator | right_operand | result |
      | RollerOne    | +        | 20            | 50     |
      | RollerOne    | -        | 20            | 10     |
      | RollerOne    | *        | 2             | 60     |
      | RollerOne    | /        | 2             | 15     |
      | RollerOne    | %        | 4             | 2      |
      | 20           | +        | RollerOne     | 50     |
      | 50           | -        | RollerOne     | 20     |
      | 2            | *        | RollerOne     | 60     |
      | 60           | /        | RollerOne     | 2      |
      | 80           | %        | RollerOne     | 20     |

  Scenario: Rollershutter work in case statements
    Given item "RollerOne" state is changed to "<initial>"
    And code in a rules file
      """
      case RollerOne
      when UP then logger.info('RollerOne is UP')
      when DOWN then logger.info('RollerOne is DOWN')
      when (51...100) then logger.info('RollerOne is in range 51...100')
      when (1..50) then logger.info('RollerOne is in range 1..50')
      end
      """
    When I deploy the rules file
    Then It should log 'RollerOne is <result>' within 5 seconds
    Examples:
      | initial | result         |
      | 0       | UP             |
      | 100     | DOWN           |
      | 25      | in range 1..50 |
