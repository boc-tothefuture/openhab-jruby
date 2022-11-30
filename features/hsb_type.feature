Feature:  hsb_type
  Rule languages supports extensions to HSBType

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario: HSBType is inspectable
    Given code in a rules file
      """
      logger.info("HSBType inspected: #{HSBType.new.inspect}")
      """
    When I deploy the rules file
    Then It should log "HSBType inspected: 0 °,0%,0%" within 5 seconds

  Scenario: HSBType can be constructed from a hex string
    Given code in a rules file
      """
      begin
      logger.info("HSBType from hex: #{HSBType.new('#abcdef').to_hex}")
      rescue => e
      logger.error("#{e}: #{e.backtrace.join("\n")}")
      raise
      end
      """
    When I deploy the rules file
    Then It should log "HSBType from hex: #aacbed" within 5 seconds

  Scenario Outline: HSBType responds to on? and off?
    Given code in a rules file
      """
      logger.info("HSBType is on: #{<state>.on?}")
      logger.info("HSBType is off: #{<state>.off?}")
      """
    When I deploy the rules file
    Then It should log "HSBType is on: <on>" within 5 seconds
    And It should log "HSBType is off: <off>" within 5 seconds
    Examples:
      | state                | on    | off   |
      | HSBType::BLACK       | false | true  |
      | HSBType::WHITE       | true  | false |
      | HSBType::RED         | true  | false |
      | HSBType.new(0, 0, 5) | true  | false |
