Feature:  stop_move_type
  Rule languages supports extensions to StopMoveType

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario: StopMoveType is inspectable
    Given code in a rules file
      """
      logger.info("StopMoveType inspected: #{STOP.inspect}")
      """
    When I deploy the rules file
    Then It should log "StopMoveType inspected: STOP" within 5 seconds
