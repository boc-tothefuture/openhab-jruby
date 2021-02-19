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
    Then It should log "run event.item class is OpenHAB::DSL::Groups::Group" within 5 seconds
    And It should log "triggered item class is OpenHAB::DSL::Groups::Group" within 5 seconds
    Examples: Test different triggers
      | trigger          |
      # | updated          | # Groups don't seem to receive Updated triggers
      | changed          |
      | received_command |
