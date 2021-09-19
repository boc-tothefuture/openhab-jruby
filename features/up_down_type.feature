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
