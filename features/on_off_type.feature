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
