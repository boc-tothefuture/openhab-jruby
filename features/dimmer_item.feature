Feature:  dimmer_item
  Rule languages supports Dimmers

  Background:
    Given Clean OpenHAB with latest Ruby Libraries
    And group "Dimmers"
    And items:
      | type   | name      | label      | group   | state |
      | Dimmer | DimmerOne | Dimmer One | Dimmers | 50    |
      | Dimmer | DimmerTwo | Dimmer Two | Dimmers | 50    |

  Scenario Outline: on/off sends commands to a Dimmer
    Given item states:
      | item      | state           |
      | DimmerOne | <initial_state> |
      | DimmerTwo | <initial_state  |
    And code in a rules file
      """
        # Turn on all dimmers in group
        Dimmers.each(&:<command>)
      """
    When I deploy the rules file
    Then "DimmerOne" should be in state "<final_state>" within 5 seconds
    And "DimmerTwo" should be in state "<final_state>" within 5 seconds
    Examples:
      | initial_state | command | final_state |
      | OFF           | on      | 100         |
      | ON            | off     | 0           |

  Scenario Outline: on?/off? checks state of dimmer
    Given item states:
      | item      | state           |
      | DimmerOne | <initial_state> |
    And code in a rules file
      """
      # Turn on switches in opposite state
      Dimmers.select(&:<check>).each(&:<command>)
      """
    When I deploy the rules file
    Then "DimmerOne" should be in state "<final_state>" within 5 seconds
    Examples:
      | initial_state | check | command | final_state |
      | 0             | off?  | on      | 100         |
      | 100           | on?   | off     | 0           |

  Scenario Outline: dim and brighten incease or decrease dimmer brightness
    Given item states:
      | item      | state           |
      | DimmerOne | <initial_state> |
    And code in a rules file
      """
      # Turn on switches in opposite state
      <command>
      """
    When I deploy the rules file
    Then "DimmerOne" should be in state "<final_state>" within 5 seconds
    Examples:
      | initial_state | command              | final_state |
      | 50            | DimmerOne.dim 2      | 48          |
      | 50            | DimmerOne.brighten 2 | 52          |

  Scenario Outline: dim/-=/brighten/+= of 1 should send the decrease command
    Given code in a rules file
      """
      # Turn on switches in opposite state
      <command>
      """
    When I deploy the rules file
    Then It should log "Sending Command <command_log> to Dimmer One" within 5 seconds
    Examples:
      | command            | command_log |
      | DimmerOne.dim      | DECREASE    |
      | DimmerOne.brighten | INCREASE    |


  Scenario: Dimmer should work with grep
    Given code in a rules file
      """
      # Get all dimmers
      items.grep(Dimmer)
           .each { |dimmer| logger.info("#{dimmer.id} is a Dimmer") }
      """
    When I deploy the rules file
    Then It should log "Dimmer One is a Dimmer" within 5 seconds


  Scenario: Dimmer should work with grep in ranges
    Given item states:
      | item      | state |
      | DimmerOne | 49    |
      | DimmerTwo | 51    |
    And code in a rules file

      """
      # Get dimmers with a state of less than 50
      items.grep(Dimmer)
           .grep(0...50)
           .each { |item| logger.info("#{item.id} is less than 50") }
      """
    When I deploy the rules file
    Then It should log "Dimmer One is less than 50" within 5 seconds
    But It should not log "Dimmer Two is less than 50" within 5 seconds

  Scenario: Switch states work in cases
    Given item states:
      | item      | state |
      | DimmerOne | 49    |
      | DimmerTwo | 51    |
    And code in a rules file
      """
      #Log dimmer states partioning at 50%
      items.grep(Dimmer)
           .each do |dimmer|
              case dimmer
              when (0..50)
                logger.info("#{dimmer.id} is less than 50%")
              when (51..100)
                logger.info("#{dimmer.id} is greater than 50%")
              end
           end
      """
    When I deploy the rules file
    Then It should log "Dimmer One is less than 50%" within 5 seconds
    And It should log "Dimmer Two is greater than 50%" within 5 seconds