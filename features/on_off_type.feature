Feature:  on_off_type
  Rule languages supports extensions to OnOffType

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario: OnOffType is inspectable
    Given code in a rules file
      """
      logger.info("OnOffType inspected: #{ON.inspect}")
      """
    When I deploy the rules file
    Then It should log "OnOffType inspected: ON" within 5 seconds

  Scenario Outline: OnOffType respond to on? and off?
    Given code in a rules file
      """
      logger.info("OnOffType is on: #{<state>.on?}")
      logger.info("OnOffType is off: #{<state>.off?}")
      """
    When I deploy the rules file
    Then It should log "OnOffType is on: <on>" within 5 seconds
    And It should log "OnOffType is off: <off>" within 5 seconds
    Examples:
      | state | on    | off   |
      | ON    | true  | false |
      | OFF   | false | true  |

  Scenario Outline: OnOffType can be used in case statements
    Given items:
      | type   | name    | state   |
      | Switch | Switch1 | <state> |
    And code in a rules file
      """
      case Switch1
      when ON then logger.info('Switch1 is on')
      when OFF then logger.info('Switch1 is off')
      else logger.info('Switch1 is unknown')
      end
      """
    When I deploy the rules file
    Then It should log "Switch1 is <result>" within 5 seconds
    Examples:
      | state | result |
      | ON    | on     |
      | OFF   | off    |
