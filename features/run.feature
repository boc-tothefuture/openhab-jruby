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
          logger.info("#{event.item.id} triggered to #{event.state}")
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
        run { |event| logger.info("#{event.item.id} triggered from #{event.last} to #{event.state}") }
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
          logger.info("#{event.item.id} triggered")
          logger.info("from #{event.last}") if event.last
          logger.info("to #{event.last}") if event.state
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
        run { |event| logger.info("#{event.item.id} triggered") }
        run { |event| logger.info("from #{event.last}") if event.last }
        run { |event| logger.info("to #{event.last}") if event.state  }
      end
      """
    When I deploy the rule
    And item "TestSwitch" state is changed to "ON"
    Then It should log 'Test Switch triggered' within 5 seconds
    Then It should log 'from OFF' within 5 seconds
    Then It should log 'to ON' within 5 seconds

  Scenario Outline: Verify decoration of event.item
    Given items:
      | type   | name    | state |
      | Number | Number1 | 1     |
    And code in a rules file
      """
      rule 'Run and triggered event item' do
        <trigger> Number1
        run { |event| logger.info("run event.item class is #{event.item.class}") }
        triggered { |item| logger.info("triggered item class is #{item.class}") }
      end
      """
    When I deploy the rules file
    And item "Number1" state is changed to "2"
    Then It should log "run event.item class is OpenHAB::DSL::Items::NumberItem" within 5 seconds
    And It should log "triggered item class is OpenHAB::DSL::Items::NumberItem" within 5 seconds
    Examples: Test different triggers
      | trigger          |
      | updated          |
      | changed          |
      | received_command |

  Scenario Outline: Verify decoration of event.item on a group
    Given groups:
      | type   | name     | function | params |
      | Switch | Switches | OR       | ON,OFF |
    And items:
      | type   | name       | group    | state |
      | Switch | Switch_One | Switches | OFF   |
    And code in a rules file
      """
    rule 'Run and triggered event item on a group' do
      <trigger> Switches
      run { |event| logger.info("run event.item class is #{event.item.class}") }
      triggered { |item| logger.info("triggered item class is #{item.class}") }
    end
      """
    When I deploy the rules file
    And item "Switches" state is changed to "ON"
    Then It should log "run event.item class is OpenHAB::DSL::Items::GroupItem" within 5 seconds
    And It should log "triggered item class is OpenHAB::DSL::Items::GroupItem" within 5 seconds
    Examples: Test different triggers
      | trigger          |
      # | updated          | # Groups don't seem to receive Updated triggers
      | changed          |
      | received_command |

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
          logger.info("event is null: #{event.null?}")
          logger.info("event is undef: #{event.undef?}")
          logger.info("event state?: #{event.state?}")
          logger.info("event state: #{event.state.inspect}")
          logger.info("event was null: #{event.was_null?}")
          logger.info("event was undef: #{event.was_undef?}")
          logger.info("event was?: #{event.was?}")
          logger.info("event was: #{event.was.inspect}")
        end
      end
      """
    When update state for item "TestSwitch" to "<initial_state>"
    And I deploy the rules file
    And update state for item "TestSwitch" to "<updated_state>"
    Then It should log "event is null: <new_null>" within 5 seconds
    And It should log "event is undef: <new_undef>" within 5 seconds
    And It should log "event state?: <new_state_p>" within 5 seconds
    And It should log "event state: <new_state>" within 5 seconds
    And It should log "event was null: <was_null>" within 5 seconds
    And It should log "event was undef: <was_undef>" within 5 seconds
    And It should log "event was?: <was_state_p>" within 5 seconds
    And It should log "event was: <was_state>" within 5 seconds
    Examples: Test different states
      | initial_state | updated_state | new_null | new_undef | new_state_p | new_state | was_null | was_undef | was_state_p | was_state |
      | ON            | NULL          | true     | false     | false       | nil       | false    | false     | true        | ON        |
      | ON            | UNDEF         | false    | true      | false       | nil       | false    | false     | true        | ON        |
      | NULL          | ON            | false    | false     | true        | ON        | true     | false     | false       | nil       |
      | UNDEF         | ON            | false    | false     | true        | ON        | false    | true      | false       | nil       |
