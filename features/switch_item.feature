Feature:  switch_item
  Rule languages supports Switches

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario Outline: Switches respond to off/on and off?/on?
    Given items:
      | type   | name       | label       | state           |
      | Switch | TestSwitch | Test Switch | <initial_state> |
    And code in a rules file
      """
     # Invert all switches
      items.select { |item| item.is_a? Switch }
           .each   { |switch| if switch.off? then switch.on else switch.off end}
      """
    When I deploy the rules file
    Then "TestSwitch" should be in state "<final_state>" within 5 seconds
    Examples:
      | initial_state | final_state |
      | ON            | OFF         |
      | OFF           | ON          |

    Scenario Outline: Switches accept boolean values
    Given items:
      | type   | name       | label       | state           |
      | Switch | TestSwitch | Test Switch | <initial_state> |
    And code in a rules file
      """
      TestSwitch << <bool>
      """
    When I deploy the rules file
    Then "TestSwitch" should be in state "<final_state>" within 5 seconds
    Examples:
      | initial_state | bool   | final_state |
      | OFF           | true   | ON          |
      | ON            | false  | OFF         |

  Scenario Outline: Switches respond to toggle
    Given items:
      | type   | name       | label       | state           |
      | Switch | TestSwitch | Test Switch | <initial_state> |
    And code in a rules file
      """
      # Invert all switches
      items.select { |item| item.is_a? Switch }
           .each   { |switch| switch.toggle }
      """
    When I deploy the rules file
    Then "TestSwitch" should be in state "<final_state>" within 5 seconds
    Examples:
      | initial_state | final_state |
      | ON            | OFF         |
      | OFF           | ON          |
      | UNDEF         | ON          |
      | NULL          | ON          |

  Scenario Outline: Switches support ! (not) operator to invert the state
    Given items:
      | type   | name       | label       | state           |
      | Switch | TestSwitch | Test Switch | <initial_state> |
    And code in a rules file
      """
      # Invert all switches
      items.select { |item| item.is_a? Switch }
           .each   { |switch| switch << !switch }
      """
    When I deploy the rules file
    Then "TestSwitch" should be in state "<final_state>" within 5 seconds
    Examples:
      | initial_state | final_state |
      | ON            | OFF         |
      | OFF           | ON          |
      | NULL          | ON          |
      | UNDEF         | ON          |

  Scenario: Switches respond to grep
    Given items:
      | type   | name       | label       | state |
      | Switch | TestSwitch | Test Switch | ON    |
    And code in a rules file
      """
      items.grep(Switch)
           .each { |switch| logger.info("Switch #{switch.id} found") }
      """
    When I deploy the rules file
    Then It should log 'Switch Test Switch found' within 5 seconds

  Scenario: Switch states work in grep
    Given items:
      | type   | name          | label           | state |
      | Switch | TestSwitch    | Test Switch     | ON    |
      | Switch | TestSwitchTwo | Test Switch Two | OFF   |
    And code in a rules file
      """
      items.grep(Switch)
           .grep(ON)
           .each { |switch| logger.info("#{switch.id} ON") }

      items.grep(Switch)
           .grep(OFF)
           .each { |switch| logger.info("#{switch.id} OFF") }
      """
    When I deploy the rules file
    Then It should log "Test Switch ON" within 5 seconds
    Then It should log "Test Switch Two OFF" within 5 seconds

  Scenario: Switch states work in cases
    Given items:
      | type   | name          | label           | state |
      | Switch | TestSwitch    | Test Switch     | ON    |
      | Switch | TestSwitchTwo | Test Switch Two | OFF   |
    And code in a rules file
      """
      items.grep(Switch)
           .each do |switch|
              case switch
              when ON
                logger.info("#{switch.id} ON")
              when OFF
                logger.info("#{switch.id} OFF")
              end
           end
      """
    When I deploy the rules file
    Then It should log "Test Switch ON" within 5 seconds
    Then It should log "Test Switch Two OFF" within 5 seconds

  Scenario Outline: on/off sends commands to a switch
    Given group "Switches"
    Given items:
      | type   | name          | label           | state           | group    |
      | Switch | TestSwitch    | Test Switch     | <initial_state> | Switches |
      | Switch | TestSwitchTwo | Test Switch Two | <initial_state> | Switches |
    And code in a rules file
      """
        Switches.each(&:<command>)
      """
    When I deploy the rules file
    Then "TestSwitch" should be in state "<final_state>" within 5 seconds
    And "TestSwitchTwo" should be in state "<final_state>" within 5 seconds
    Examples:
      | initial_state | command | final_state |
      | OFF           | on      | ON          |
      | ON            | off     | OFF         |

  Scenario Outline: on?/off? checks state of switch
    Given group "Switches"
    Given items:
      | type   | name          | label           | state           | group    |
      | Switch | TestSwitch    | Test Switch     | <initial_state> | Switches |
      | Switch | TestSwitchTwo | Test Switch Two | <initial_state> | Switches |
    And code in a rules file
      """
        Switches.select(&:<check>).each(&:<command>)
      """
    When I deploy the rules file
    Then "TestSwitch" should be in state "<final_state>" within 5 seconds
    And "TestSwitchTwo" should be in state "<final_state>" within 5 seconds
    Examples:
      | initial_state | check | command | final_state |
      | OFF           | off?  | on      | ON          |
      | ON            | on?   | off     | OFF         |

