Feature:  string_type
  Rule languages supports extensions to StringType

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario: StringType is inspectable
    Given code in a rules file
      """
      java_import org.openhab.core.library.types.StringType
      logger.info("StringType inspected: #{StringType.new('my_string')}")
      """
    When I deploy the rules file
    Then It should log "StringType inspected: my_string" within 5 seconds

  Scenario: StringType can be used in a case with a regex
    Given code in a rules file
      """
      java_import org.openhab.core.library.types.StringType
      case StringType.new("hi")
      when /hi/ then logger.info("matched")
      else
        logger.info("did not match")
      end
      """
    When I deploy the rules file
    Then It should log "matched" within 5 seconds
