Feature: player_item
  Player Items are supported

  Background:
    Given Clean OpenHAB with latest Ruby Libraries
    And items:
      | type   | name   |
      | Player | Player |

  Scenario: Sending command to a PlayerItem is supported
    Given code in a rules file
      """
      Player << <command>
      """
    When I deploy the rules file
    Then "Player" should be in state "<command>" within 5 seconds
    Examples:
      | command     |
      | PLAY        |
      | PAUSE       |
      | REWIND      |
      | FASTFORWARD |

  Scenario: Next/previous is sent to player items
    Given code in a rules file
      """
      Player << <command>
      """
    When I deploy the rules file
    Then It should log "Sending Command <command> to Player" within 5 seconds
    Examples:
      | command  |
      | NEXT     |
      | PREVIOUS |

  Scenario: Sending command methods to a PlayerItem is supported
    Given code in a rules file
      """
      Player.<command>
      """
    When I deploy the rules file
    Then "Player" should be in state "<state>" within 5 seconds
    Examples:
      | command      | state       |
      | play         | PLAY        |
      | pause        | PAUSE       |
      | rewind       | REWIND      |
      | fastforward  | FASTFORWARD |
      | fast_forward | FASTFORWARD |

  Scenario: State check commands
    Given item "Player" state is changed to "<state>"
    #    Given items:
    #      | type   | name        | state   |
    #      | Player | PlayerCheck | <state> |
    And code in a rules file
      """
      logger.info("<check> #{Player.<check>}")
      """
    When I deploy the rules file
    Then It should log "<check> true" within 5 seconds
    Examples:
      | check            | state       |
      | playing?         | PLAY        |
      | paused?          | PAUSE       |
      | rewinding?       | REWIND      |
      | fastforwarding?  | FASTFORWARD |
      | fast_forwarding? | FASTFORWARD |

  Scenario: Next/previous is sent to player items when invoked as a method
    Given code in a rules file
      """
      Player.<command>
      """
    When I deploy the rules file
    Then It should log "Sending Command <command_name> to Player" within 5 seconds
    Examples:
      | command  | command_name |
      | next     | NEXT         |
      | previous | PREVIOUS     |


