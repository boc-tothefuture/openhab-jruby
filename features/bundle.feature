Feature: bundle
  Verify the jrubyscripting bundle

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  @wip
  Scenario: Check bundle version
    Given The version of 'org.openhab.automation.jrubyscripting' bundle is '3.3.0.202201150335'
    And a rule
      """
      logger.info 'Hello'
      """
    When I deploy the rule
    Then It should log 'Hello' within 5 seconds

