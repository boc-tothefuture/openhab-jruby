Feature:  triggered
  Automation is executed in triggered blocks

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario: rules have access to triggering item in triggered blocks
    Given items:
      | type   | name       | label       | state |
      | Switch | TestSwitch | Test Switch | OFF   |
    Given a deployed rule:
      """
      rule 'Triggered has access directly to item triggered' do
        changed TestSwitch
        triggered { |item| logger.info("#{item.name} triggered") }
      end
      """
    When item "TestSwitch" state is changed to "ON"
    Then It should log 'Test Switch triggered' within 5 seconds


  Scenario: Triggered item is item modified in group
    Given group "Switches"
    And items:
      | type   | name    | label             | state | group    |
      | Switch | Switch1 | Switch Number One | OFF   | Switches |
      | Switch | Switch2 | Switch Number Two | OFF   | Switches |
    And a deployed rule:
      """
      rule 'Triggered item is item changed when a group item is changed.' do
        changed Switches.members
        triggered { |item| logger.info("Switch #{item.name} changed to #{item}")}
      end
      """
    When item "Switch1" state is changed to "ON"
    Then It should log 'Switch Switch Number One changed to ON' within 5 seconds

  Scenario: Triggered supports pretzel colon (&:) operator
    Given group "Switches"
    And items:
      | type   | name    | label             | state | group    |
      | Switch | Switch1 | Switch Number One | OFF   | Switches |
      | Switch | Switch2 | Switch Number Two | OFF   | Switches |
    And a deployed rule:
      """
      rule 'Turn off any switch that changes' do
        changed Switches.members
        triggered(&:off)
      end
      """
    When item "Switch1" state is changed to "ON"
    And if I wait 1 seconds
    Then "Switch1" should be in state "OFF" within 5 seconds

  Scenario: Multiple triggers in a rule
    Given group "Switches"
    And items:
      | type   | name    | label             | state | group    |
      | Switch | Switch1 | Switch Number One | OFF   | Switches |
      | Switch | Switch2 | Switch Number Two | OFF   | Switches |
    And a deployed rule:
      """
      rule 'Turn a switch off and log it, 5 seconds after turning it on' do
        changed Switches.members, to: ON
        delay 5.seconds
        triggered(&:off)
        triggered {|item| logger.info("#{item.label} turned off") }
      end
      """
    When item "Switch1" state is changed to "ON"
    And if I wait 1 seconds
    Then "Switch1" should be in state "OFF" within 6 seconds
    And It should log 'Switch Number One turned off' within 5 seconds
