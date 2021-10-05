Feature:  increase_decrease_type
  Rule languages supports extensions to IncreaseDecreaseType

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario: IncreaseDecreaseType is inspectable
    Given code in a rules file
      """
      logger.info("IncreaseDecreaseType inspected: #{INCREASE.inspect}")
      """
    When I deploy the rules file
    Then It should log "IncreaseDecreaseType inspected: INCREASE" within 5 seconds
