Feature:  states
  Rule languages supports states processing

  Background:
    Given Clean OpenHAB with latest Ruby Libraries
    And items:
      | type   | name    | label             | state |
      | Switch | Switch1 | Switch Number One | OFF   |
      | Switch | Switch2 | Switch Number Two | OFF   |

  Scenario: States can be stored and restored using store_states
    Given code in a rules file:
      """
      states = store_states Switch1, Switch2
      Switch1 << ON
      after(5.seconds) { states.restore }
      """
    When I deploy the rule
    Then "Switch1" should be in state "ON" within 2 seconds
    But If I wait 5 seconds
    Then "Switch1" should be in state "OFF" within 2 seconds

  Scenario: States can be stored and restored using store_states block
    Given code in a rules file:
      """
      store_states Switch1, Switch2 do
        Switch1 << ON
        sleep 5
      end
      """
    When I start deploying the rule
    Then "Switch1" should be in state "ON" within 2 seconds
    But If I wait 5 seconds
    Then "Switch1" should be in state "OFF" within 2 seconds

  Scenario Outline: Check item states
    Given code in a rules file:
      """
      Switch1.update <state>
      sleep 0.5
      if state? Switch1, Switch2
        logger.info "All items have a valid state"
      else
        logger.info "Some states are nil"
      end
      """
    When I start deploying the rule
    Then It <should> log "All items have a valid state" within 3 seconds
    And It <should_not> log "Some states are nil" within 3 seconds
    Examples:
      | state | should     | should_not |
      | ON    | should     | should not |
      | UNDEF | should not | should     |
      | NULL  | should not | should     |

  Scenario Outline: Check item states before executing a rule
    Given code in a rules file:
      """
      Switch1.update <state>
      sleep 0.5
      rule 'state check' do
        on_start
        only_if { state? Switch1, Switch2 }
        run { logger.info "All items have a valid state" }
      end
      """
    When I deploy the rule
    Then It <should> log "All items have a valid state" within 3 seconds
    Examples:
      | state | should     |
      | ON    | should     |
      | UNDEF | should not |
      | NULL  | should not |

  Scenario Outline: Check item states and their thing status
    Given feature 'openhab-binding-astro' installed
    And things:
      | id   | thing_uid | label          | config                | status  |
      | home | astro:sun | Astro Sun Data | {"geolocation":"0,0"} | <state> |
    And items:
      | type   | name          |
      | Number | Sun_Elevation |
    And linked:
      | item          | channel                           |
      | Sun_Elevation | astro:sun:home:position#elevation |
    And a rule:
      """
      Sun_Elevation.update 0
      sleep 0.2
      logger.info "Sun_Elevation is valid? #{state? Sun_Elevation, things: true}"
      """
    When I deploy the rule
    Then It should log "Sun_Elevation is valid? <result>" within 5 seconds
    Examples:
      | state   | result |
      | enable  | true   |
      | disable | false  |
