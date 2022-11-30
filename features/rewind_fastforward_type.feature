Feature:  rewind_fastforward_type
  Rule languages supports extensions to RewindFastforwardType

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario: RewindFastforwardType is inspectable
    Given code in a rules file
      """
      logger.info("RewindFastforwardType inspected: #{REWIND.inspect}")
      """
    When I deploy the rules file
    Then It should log "RewindFastforwardType inspected: REWIND" within 5 seconds
