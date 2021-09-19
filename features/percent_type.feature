Feature:  percent_type
  Rule languages supports extensions to PercentType

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario: PercentType is inspectable
    Given code in a rules file
      """
      java_import org.openhab.core.library.types.PercentType
      logger.info("PercentType inspected: #{PercentType.new(10).inspect}")
      """
    When I deploy the rules file
    Then It should log "PercentType inspected: 10%" within 5 seconds
