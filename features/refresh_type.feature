Feature:  refresh_type
  Rule languages supports extensions to RefreshType

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario: RefreshType is inspectable
    Given code in a rules file
      """
      logger.info("RefreshType inspected: #{REFRESH.inspect}")
      """
    When I deploy the rules file
    Then It should log "RefreshType inspected: REFRESH" within 5 seconds
