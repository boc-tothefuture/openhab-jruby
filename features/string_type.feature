Feature:  string_type
  Rule languages supports extensions to StringType

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario: UpDownType is inspectable
    Given code in a rules file
      """
      java_import org.openhab.core.library.types.StringType
      logger.info("StringType inspected: #{StringType.new('my_string')}")
      """
    When I deploy the rules file
    Then It should log "StringType inspected: my_string" within 5 seconds
