Feature:  open_closed_type
  Rule languages supports extensions to OpenClosedType

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario: OpenClosedType is inspectable
    Given code in a rules file
      """
      logger.info("OpenClosedType inspected: #{CLOSED.inspect}")
      """
    When I deploy the rules file
    Then It should log "OpenClosedType inspected: CLOSED" within 5 seconds
