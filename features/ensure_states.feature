Feature:  ensure_states
  Rule languages has ensure_states feature

  Background:
    Given Clean OpenHAB with latest Ruby Libraries
    And groups:
      | type   | name    | function |
      | Dimmer | Dimmers | AVG      |
    And items:
      | type   | name      | label      | group   | state |
      | Dimmer | DimmerOne | Dimmer One | Dimmers | 50    |
      | Dimmer | DimmerTwo | Dimmer Two | Dimmers | 50    |

  Scenario Outline: ensure sends commands if not in given state
    Given item states:
      | item      | state           |
      | DimmerOne | <initial_state> |
    And code in a rules file
      """
        rule "command received" do
          received_command DimmerOne
          run do |event|
            logger.trace("DimmerOne received command")
          end
        end
        DimmerOne.ensure.<command>
      """
    When I deploy the rules file
    Then "DimmerOne" should be in state "<final_state>" within 5 seconds
    And It should log "DimmerOne received command" within 1 seconds
    Examples:
      | initial_state | command | final_state |
      | 0             | on      | 100         |
      | 0             | << ON   | 100         |
      | 0             | << 50   | 50          |
      | 50            | off     | 0           |
      | 50            | << OFF  | 0           |
      | 50            | << 100  | 100         |
      | 100           | off     | 0           |
      | 100           | << OFF  | 0           |
      | 100           | << 0    | 0           |

  Scenario Outline: ensure does not send commands if already in given state
    Given item states:
      | item      | state           |
      | DimmerOne | <initial_state> |
    And code in a rules file
      """
        rule "command received" do
          received_command DimmerOne
          run do |event|
            logger.trace("DimmerOne received command")
          end
        end
        DimmerOne.ensure.<command>
        logger.trace("Command sent")
      """
    When I deploy the rules file
    Then It should log "Command sent" within 5 seconds
    And "DimmerOne" should be in state "<final_state>" within 1 seconds
    And It should not log "DimmerOne received command" within 1 seconds
    Examples:
      | initial_state | command | final_state |
      | 0             | off     | 0           |
      | 0             | << OFF  | 0           |
      | 0             | << 0    | 0           |
      | 50            | on      | 50          |
      | 50            | << ON   | 50          |
      | 50            | << 50   | 50          |
      | 100           | on      | 100         |
      | 100           | << ON   | 100         |
      | 100           | << 100  | 100         |

  Scenario Outline: ensure sends commands to group if not in given state
    Given item states:
      | item      | state            |
      | DimmerOne | <initial_state1> |
      | DimmerTwo | <initial_state2> |
    And code in a rules file
      """
        rule "command received" do
          received_command DimmerOne
          run do |event|
            logger.trace("DimmerOne received command")
          end
        end
        Dimmers.ensure.<command>
      """
    When I deploy the rules file
    Then "DimmerOne" should be in state "<final_state1>" within 5 seconds
    And "DimmerTwo" should be in state "<final_state2>" within 1 seconds
    And It should log "DimmerOne received command" within 1 seconds
    Examples:
      | initial_state1 | initial_state2 | command | final_state1 | final_state2 |
      | 0              | 0              | on      | 100          | 100          |
      | 0              | 0              | << ON   | 100          | 100          |
      | 0              | 0              | << 50   | 50           | 50           |
      | 50             | 0              | off     | 0            | 0            |
      | 50             | 0              | << OFF  | 0            | 0            |
      | 50             | 0              | << 100  | 100          | 100          |

  Scenario Outline: ensure does not send commands to group if in given state
    Given item states:
      | item      | state            |
      | DimmerOne | <initial_state1> |
      | DimmerTwo | <initial_state2> |
    And code in a rules file
      """
        rule "command received" do
          received_command DimmerOne
          run do |event|
            logger.trace("DimmerOne received command")
          end
        end
        Dimmers.ensure.<command>
        logger.trace("Command sent")
      """
    When I deploy the rules file
    Then It should log "Command sent" within 5 seconds
    And "DimmerOne" should be in state "<final_state1>" within 1 seconds
    And "DimmerTwo" should be in state "<final_state2>" within 1 seconds
    And It should not log "DimmerOne received command" within 1 seconds
    Examples:
      | initial_state1 | initial_state2 | command | final_state1 | final_state2 |
      | 0              | 0              | off     | 0            | 0            |
      | 0              | 0              | << OFF  | 0            | 0            |
      | 100            | 0              | << 50   | 100          | 0            |

  Scenario Outline: ensure sends commands memberwise to group if not in given state
    Given item states:
      | item      | state            |
      | DimmerOne | <initial_state1> |
      | DimmerTwo | <initial_state2> |
    And code in a rules file
      """
        rule "command received" do
          received_command DimmerOne
          run do |event|
            logger.trace("DimmerOne received command")
          end
        end
        Dimmers.members.ensure.<command>
      """
    When I deploy the rules file
    Then "DimmerOne" should be in state "<final_state1>" within 5 seconds
    And "DimmerTwo" should be in state "<final_state2>" within 1 seconds
    And It should log "DimmerOne received command" within 1 seconds
    Examples:
      | initial_state1 | initial_state2 | command | final_state1 | final_state2 |
      | 0              | 100            | on      | 100          | 100          |
      | 0              | 100            | << ON   | 100          | 100          |
      | 0              | 100            | << 50   | 50           | 50           |

  Scenario: ensure_states does not send commands if already in given state
    Given item states:
      | item      | state |
      | DimmerOne | 0     |
    And code in a rules file
      """
        rule "command received" do
          received_command DimmerOne
          run do |event|
            logger.trace("DimmerOne received command")
          end
        end
        ensure_states do
          DimmerOne.off
        end
        logger.trace("Command sent")
      """
    When I deploy the rules file
    Then It should log "Command sent" within 5 seconds
    And "DimmerOne" should be in state "0" within 1 seconds
    And It should not log "DimmerOne received command" within 1 seconds
