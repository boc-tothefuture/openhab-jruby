Feature:  run
  Automation is executed in run blocks

  Background:
    Given Clean OpenHAB with latest Ruby Libraries
    And items:
      | type   | name       | label       | state |
      | Switch | TestSwitch | Test Switch | OFF   |

  Scenario Outline: Rules have access to event information in run blocks
    Given a rule
      """
      rule 'Access Event Properties' do
        <trigger> TestSwitch
        run do |event|
          logger.info("#{event.item.name} triggered to #{event.state}")
         end
      end
      """
    When I deploy the rule
    And item "TestSwitch" state is changed to "ON"
    Then It should log 'Test Switch triggered to ON' within 5 seconds
    Examples: Test various triggers
      | trigger |
      | updated |
      | changed |


  Scenario: Single line run blocks supported
    Given a rule
      """
      rule 'Access Event Properties' do
        changed TestSwitch
        run { |event| logger.info("#{event.item.name} triggered from #{event.was} to #{event.state}") }
      end
      """
    When I deploy the rule
    And item "TestSwitch" state is changed to "ON"
    Then It should log 'Test Switch triggered from OFF to ON' within 5 seconds

  Scenario: Multi-line run blocks supported
    Given a rule
      """
      rule 'Multi Line Run Block' do
        changed TestSwitch
        run do |event|
          logger.info("#{event.item.name} triggered")
          logger.info("from #{event.was}") if event.was
          logger.info("to #{event.state}") if event.state
        end
      end
      """
    When I deploy the rule
    And item "TestSwitch" state is changed to "ON"
    Then It should log 'Test Switch triggered' within 5 seconds
    Then It should log 'from OFF' within 5 seconds
    Then It should log 'to ON' within 5 seconds

  Scenario: Multiple run blocks supported
    Given a rule
      """
      rule 'Multiple Run Blocks' do
        changed TestSwitch
        run { |event| logger.info("#{event.item.name} triggered") }
        run { |event| logger.info("from #{event.was}") if event.was }
        run { |event| logger.info("to #{event.state}") if event.state  }
      end
      """
    When I deploy the rule
    And item "TestSwitch" state is changed to "ON"
    Then It should log 'Test Switch triggered' within 5 seconds
    Then It should log 'from OFF' within 5 seconds
    Then It should log 'to ON' within 5 seconds

  Scenario Outline: Verify event state predicates on update
    And code in a rules file
      """
      rule 'log event state info' do
        updated TestSwitch
        run do |event|
          logger.info("event is null: #{event.null?}")
          logger.info("event is undef: #{event.undef?}")
          logger.info("event state?: #{event.state?}")
          logger.info("event state: #{event.state.inspect}")
        end
      end
      """
    When I deploy the rules file
    And update state for item "TestSwitch" to "<updated_state>"
    Then It should log "event is null: <null>" within 5 seconds
    And It should log "event is undef: <undef>" within 5 seconds
    And It should log "event state?: false" within 5 seconds
    And It should log "event state: nil" within 5 seconds
    Examples: Test different states
      | updated_state | null  | undef |
      | NULL      | true  | false |
      | UNDEF     | false | true  |

  Scenario Outline: Verify event state predicates on change
    And code in a rules file
      """
      rule 'log event state info' do
        changed TestSwitch
        run do |event|
          logger.info("event state: #{event.null?} #{event.undef?} #{event.state?} #{event.state.inspect}")
          logger.info("event was: #{event.was_null?} #{event.was_undef?} #{event.was?} #{event.was.inspect}")
        end
      end
      """
    When update state for item "TestSwitch" to "<initial_state>"
    And I deploy the rules file
    And update state for item "TestSwitch" to "<updated_state>"
    Then It should log "event state: <new_null> <new_undef> <new_state_p> <new_state>" within 5 seconds
    And It should log "event was: <was_null> <was_undef> <was_state_p> <was_state>" within 5 seconds
    Examples: Test different states
      | initial_state | updated_state | new_null | new_undef | new_state_p | new_state | was_null | was_undef | was_state_p | was_state |
      | ON            | NULL          | true     | false     | false       | nil       | false    | false     | true        | ON        |
      | ON            | UNDEF         | false    | true      | false       | nil       | false    | false     | true        | ON        |
      | NULL          | ON            | false    | false     | true        | ON        | true     | false     | false       | nil       |
      | UNDEF         | ON            | false    | false     | true        | ON        | false    | true      | false       | nil       |
