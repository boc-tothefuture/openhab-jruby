Feature:  next_previous_type
  Rule languages supports extensions to NextPreviousType

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario: NextPreviousType is inspectable
    Given code in a rules file
      """
      logger.info("NextPreviousType inspected: #{NEXT.inspect}")
      """
    When I deploy the rules file
    Then It should log "NextPreviousType inspected: NEXT" within 5 seconds
