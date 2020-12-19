Feature:  Openhab Action Support

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario: Rules have access to event information in run blocks
    Given items:
      | type   | name       | label       | state |
      | Switch | TestSwitch | Test Switch | OFF   |
    Given a rule
      """
      rule 'Access Event Properties' do
        changed TestSwitch
        run do |event|
          logger.info("#{event.item.id} triggered from #{event.last} to #{event.state}")
         end
      end
      """
    When I deploy the rule
    And item "TestSwitch" state is changed to "ON"
    Then It should log 'Test Switch triggered from OFF to ON' within 5 seconds


  Scenario: Single line run blocks supported
    Given items:
      | type   | name       | label       | state |
      | Switch | TestSwitch | Test Switch | OFF   |
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
    Given items:
      | type   | name       | label       | state |
      | Switch | TestSwitch | Test Switch | OFF   |
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
    Given items:
      | type   | name       | label       | state |
      | Switch | TestSwitch | Test Switch | OFF   |
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


