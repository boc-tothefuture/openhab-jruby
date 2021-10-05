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

  Scenario Outline: PercentType responds to on?, off?, up?, and down?
    Given code in a rules file
      """
      java_import org.openhab.core.library.types.PercentType
      state = PercentType.new(<state>)
      logger.info("PercentType is up: #{state.up?}")
      logger.info("PercentType is down: #{state.down?}")
      logger.info("PercentType is on: #{state.on?}")
      logger.info("PercentType is off: #{state.off?}")
      """
    When I deploy the rules file
    Then It should log "PercentType is up: <up>" within 5 seconds
    And It should log "PercentType is down: <down>" within 5 seconds
    Then It should log "PercentType is on: <on>" within 5 seconds
    And It should log "PercentType is off: <off>" within 5 seconds
    Examples:
      | state | up    | down  | on    | off   |
      | 0     | true  | false | false  | true |
      | 50    | false | false | true | false |
      | 100   | false | true  | true | false  |