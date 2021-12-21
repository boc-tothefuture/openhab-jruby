Feature: month_day
  Rule languages supports MonthDay

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario: MonthDay supports keyword arguments
    Given a rule:
      """
      md = MonthDay.new(m: 12, d: 25)
      logger.info("md: #{md}")
      """
    When I deploy the rule
    Then It should log "md: 12-25" within 5 seconds
