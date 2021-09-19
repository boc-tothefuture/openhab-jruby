Feature:  play_pause_type
  Rule languages supports extensions to PlayPauseType

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario: PlayPauseType is inspectable
    Given code in a rules file
      """
      logger.info("PlayPauseType inspected: #{PLAY.inspect}")
      """
    When I deploy the rules file
    Then It should log "PlayPauseType inspected: PLAY" within 5 seconds
