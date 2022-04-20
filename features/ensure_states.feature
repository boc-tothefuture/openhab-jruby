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
          <trigger_type> DimmerOne
          run do |event|
            logger.trace("DimmerOne <trigger_type>")
          end
        end
        DimmerOne.ensure.<command>
      """
    When I deploy the rules file
    Then "DimmerOne" should be in state "<final_state>" within 5 seconds
    And It should log "DimmerOne <trigger_type>" within 5 seconds
    Examples:
      | initial_state | command     | final_state | trigger_type     |
      | 0             | on          | 100         | received_command |
      | 0             | << ON       | 100         | received_command |
      | 0             | update(ON)  | 100         | updated          |
      | 0             | << 50       | 50          | received_command |
      | 0             | update(50)  | 50          | updated          |
      | 50            | off         | 0           | received_command |
      | 50            | << OFF      | 0           | received_command |
      | 50            | update(OFF) | 0           | updated          |
      | 50            | << 100      | 100         | received_command |
      | 50            | update(100) | 100         | updated          |
      | 100           | off         | 0           | received_command |
      | 100           | << OFF      | 0           | received_command |
      | 100           | << 0        | 0           | received_command |
      | 100           | update(0)   | 0           | updated          |
      | 100           | update(OFF) | 0           | updated          |

  Scenario Outline: ensure does not send commands if already in given state
    Given item states:
      | item      | state           |
      | DimmerOne | <initial_state> |
    And code in a rules file
      """
        rule "command received" do
          <trigger_type> DimmerOne
          run do |event|
            logger.trace("DimmerOne <trigger_type>")
          end
        end
        DimmerOne.ensure.<command>
        logger.trace("Command sent")
      """
    When I deploy the rules file
    Then It should log "Command sent" within 5 seconds
    And "DimmerOne" should be in state "<final_state>" within 5 seconds
    And It should not log "DimmerOne <trigger_type>" within 5 seconds
    Examples:
      | initial_state | command     | final_state | trigger_type     |
      | 0             | off         | 0           | received_command |
      | 0             | << OFF      | 0           | received_command |
      | 0             | << 0        | 0           | received_command |
      | 0             | update(OFF) | 0           | updated          |
      | 0             | update(0)   | 0           | updated          |
      | 50            | on          | 50          | received_command |
      | 50            | << ON       | 50          | received_command |
      | 50            | << 50       | 50          | received_command |
      | 50            | update(50)  | 50          | updated          |
      | 100           | on          | 100         | received_command |
      | 100           | << ON       | 100         | received_command |
      | 100           | << 100      | 100         | received_command |
      | 100           | update(100) | 100         | updated          |

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
    And "DimmerTwo" should be in state "<final_state2>" within 5 seconds
    And It should log "DimmerOne received command" within 5 seconds
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
    And "DimmerOne" should be in state "<final_state1>" within 5 seconds
    And "DimmerTwo" should be in state "<final_state2>" within 5 seconds
    And It should not log "DimmerOne received command" within 5 seconds
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
    And "DimmerTwo" should be in state "<final_state2>" within 5 seconds
    And It should log "DimmerOne received command" within 5 seconds
    Examples:
      | initial_state1 | initial_state2 | command | final_state1 | final_state2 |
      | 0              | 100            | on      | 100          | 100          |
      | 0              | 100            | << ON   | 100          | 100          |
      | 0              | 100            | << 50   | 50           | 50           |

  Scenario Outline: ensure_states does not send commands if already in given state
    Given item states:
      | item      | state |
      | DimmerOne | 0     |
    And code in a rules file
      """
        rule "command received" do
          <trigger_type> DimmerOne
          run do |event|
            logger.trace("DimmerOne <trigger_type>")
          end
        end
        ensure_states do
          DimmerOne.<command>
        end
        logger.trace("Command sent")
      """
    When I deploy the rules file
    Then It should log "Command sent" within 5 seconds
    And "DimmerOne" should be in state "0" within 5 seconds
    And It should not log "DimmerOne <trigger_type>" within 5 seconds
    Examples:
      | command     | trigger_type     |
      | off         | received_command |
      | update(OFF) | updated          |

  Scenario Outline: ensure works with boolean commands for SwitchItem
    Given items:
      | type   | name    | state           |
      | Switch | Switch1 | <initial_state> |
    And code in a rules file
      """
        rule "command received" do
          <trigger_type> Switch1
          run do |event|
            logger.trace("Switch1 <trigger_type>")
          end
        end
        Switch1.ensure.<command>
        logger.trace("Command sent")
      """
    When I deploy the rules file
    Then It should log "Command sent" within 5 seconds
    And "Switch1" should be in state "<initial_state>" within 5 seconds
    And It should not log "Switch1 <trigger_type>" within 5 seconds
    Examples:
      | initial_state | command       | trigger_type     |
      | OFF           | command false | received_command |
      | ON            | command true  | received_command |
      | OFF           | update false  | updated          |
      | ON            | update true   | updated          |

  Scenario: ensure update doesn't send a command
    Given items:
      | type   | name    | state |
      | Switch | Switch1 | OFF   |
    And code in a rules file
      """
        rule "command received" do
          received_command Switch1
          run do |event|
            logger.trace("Switch1 received command")
          end
        end
        Switch1.ensure.update ON
        logger.trace("Item updated")
      """
    When I deploy the rules file
    Then It should log "Item updated" within 5 seconds
    And "Switch1" should be in state "ON" within 5 seconds
    And It should not log "Switch1 received command" within 5 seconds

  Scenario Outline: ensure is available on Enumerable
    Given code in a rules file
      """
      rule "command received" do
        received_command DimmerOne, DimmerTwo
        run do |event|
          logger.trace("Dimmers received command")
        end
      end
      sleep 1
      [DimmerOne, DimmerTwo].ensure.command <command>
      """
    When I deploy the rules file
    Then It <should> log "Dimmers received command" within 5 seconds
    Examples:
      | command | should     |
      | 50      | should not |
      | 10      | should     |

