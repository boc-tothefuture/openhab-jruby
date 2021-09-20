Feature:  up_down_type
  Rule languages supports extensions to UpDownType

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario: UpDownType is inspectable
    Given code in a rules file
      """
      logger.info("UpDownType inspected: #{UP.inspect}")
      """
    When I deploy the rules file
    Then It should log "UpDownType inspected: UP" within 5 seconds

  Scenario Outline: UpDownType responds to up? and down?
    Given code in a rules file
      """
      logger.info("UpDownType is up: #{<state>.up?}")
      logger.info("UpDownType is down: #{<state>.down?}")
      """
    When I deploy the rules file
    Then It should log "UpDownType is up: <up>" within 5 seconds
    And It should log "UpDownType is down: <down>" within 5 seconds
    Examples:
      | state | up    | down  |
      | UP    | true  | false |
      | DOWN  | false | true  |
