Feature:  Rule languages supports guards (only_if/not_if)

  Background:
    Given Clean OpenHAB with latest Ruby Libraries
    And group "Switches"
    And items:
      | type    | name          | label          | state | group    |
      | Dimmer  | OutsideDimmer | Test Dimmer    | 0     |          |
      | Switch  | LightSwitch   | Test Switch    | OFF   | Switches |
      | Switch  | OtherSwitch   | Other Switch   | OFF   | Switches |
      | Switch  | OutsideSwitch | Outside Switch | OFF   | Switches |
      | Contact | Door          | Test Contact   |       |          |

  Scenario Outline: only_if allows rule execution when result is true and prevents when false
    Given a deployed rule:
      """
      rule 'Set OutsideDimmer to 50% if LightSwtich turned on and OtherSwitch is also ON' do
        changed LightSwitch, to: ON
        run { OutsideDimmer << 50 }
        only_if { OtherSwitch == ON }
      end
      """
    When item "OtherSwitch" state is changed to "<other_switch_state>"
    And item "LightSwitch" state is changed to "ON"
    And if I wait 2 seconds
    Then "OutsideDimmer" should be in state "<dimmer_state>" within 5 seconds
    Examples:
      | other_switch_state | dimmer_state |
      | ON                 | 50           |
      | OFF                | 0            |

  Scenario Outline: only_if uses 'truthy?' on objects that are provided that are not blocks
    Given a deployed rule:
      """
      rule 'Set OutsideDimmer to 50% if LightSwtich turned on and OtherSwitch is also ON' do
        changed LightSwitch, to: ON
        run { OutsideDimmer << 50 }
        only_if OtherSwitch
      end
      """
    When item "OtherSwitch" state is changed to "<other_switch_state>"
    And item "LightSwitch" state is changed to "ON"
    And if I wait 2 seconds
    Then "OutsideDimmer" should be in state "<dimmer_state>" within 5 seconds
    Examples:
      | other_switch_state | dimmer_state |
      | ON                 | 50           |
      | OFF                | 0            |


  Scenario Outline: only_if supports multiple only_if statements and all must be true for rule execution
    Given a deployed rule:
      """
      rule 'Set OutsideDimmer to 50% if LightSwtich turned on and OtherSwitch is also ON and Door is closed' do
        changed LightSwitch, to: ON
        run { OutsideDimmer << 50 }
        only_if OtherSwitch
        only_if { Door == CLOSED }
      end
      """
    When item "OtherSwitch" state is changed to "<other_switch_state>"
    And update state for item "Door" to "<door_state>"
    And item "LightSwitch" state is changed to "ON"
    And if I wait 2 seconds
    Then "OutsideDimmer" should be in state "<dimmer_state>" within 5 seconds
    Examples:
      | other_switch_state | door_state | dimmer_state |
      | ON                 | OPEN       | 0            |
      | OFF                | CLOSED     | 0            |
      | ON                 | CLOSED     | 50           |
      | OFF                | CLOSED     | 0            |


  Scenario Outline: only_if and not_if raise an error if supplied objects that don't respond to 'truthy'?
    And a rule
      """
      rule 'turn  on light switch at start' do
        on_start
        changed LightSwitch, to: ON
        <guard>
      end
      """
    When I deploy a rule with an error
    Then It should log "<log_line>" within 20 seconds
    Examples:
      | guard        | log_line                                           |
      | only_if Door | Object passed to only_if must respond_to 'truthy?' |
      | not_if Door  | Object passed to not_if must respond_to 'truthy?'  |


  Scenario: not_if allows prevents execution of rules when result is false and prevents when true
    Given a deployed rule:
      """
      rule 'Set OutsideDimmer to 50% if LightSwtich turned on and OtherSwitch is OFF' do
        changed LightSwitch, to: ON
        run { OutsideDimmer << 50 }
        not_if { OtherSwitch == ON }
      end
      """
    When item "OtherSwitch" state is changed to "<other_switch_state>"
    And item "LightSwitch" state is changed to "ON"
    And if I wait 2 seconds
    Then "OutsideDimmer" should be in state "<dimmer_state>" within 5 seconds
    Examples:
      | other_switch_state | dimmer_state |
      | ON                 | 0            |
      | OFF                | 50           |


  Scenario: not_if uses 'truthy?' on objects that are provided that are not blocks
    Given a deployed rule:
      """
      rule 'Set OutsideDimmer to 50% if LightSwtich turned on and OtherSwitch is OFF' do
        changed LightSwitch, to: ON
        run { OutsideDimmer << 50 }
        not_if OtherSwitch
      end
      """
    When item "OtherSwitch" state is changed to "<other_switch_state>"
    And item "LightSwitch" state is changed to "ON"
    And if I wait 2 seconds
    Then "OutsideDimmer" should be in state "<dimmer_state>" within 5 seconds
    Examples:
      | other_switch_state | dimmer_state |
      | ON                 | 0            |
      | OFF                | 50           |


  Scenario: not_if prevents execution if multiple not_ifs are used and any of them are not satisfied
    Given a deployed rule:
      """
      rule 'Set OutsideDimmer to 50% if LightSwtich turned on and OtherSwitch is OFF and Door is not CLOSED' do
        changed LightSwitch, to: ON
        run { OutsideDimmer << 50 }
        not_if OtherSwitch
        not_if { Door == CLOSED }
      end
      """
    When item "OtherSwitch" state is changed to "<other_switch_state>"
    And update state for item "Door" to "<door_state>"
    And item "LightSwitch" state is changed to "ON"
    And if I wait 2 seconds
    Then "OutsideDimmer" should be in state "<dimmer_state>" within 5 seconds
    Examples:
      | other_switch_state | door_state | dimmer_state |
      | ON                 | OPEN       | 0            |
      | OFF                | OPEN       | 50           |
      | ON                 | CLOSED     | 0            |
      | OFF                | CLOSED     | 0            |

  Scenario: only_if and not_if most both be satisfied for a rule to execute
    Given a deployed rule:
      """
      rule 'Set OutsideDimmer to 50% if LightSwtich turned on and OtherSwitch is OFF and Door is CLOSED' do
        changed LightSwitch, to: ON
        run { OutsideDimmer << 50 }
        only_if { Door == CLOSED }
        not_if OtherSwitch
      end
      """
    When item "OtherSwitch" state is changed to "<other_switch_state>"
    And update state for item "Door" to "<door_state>"
    And item "LightSwitch" state is changed to "ON"
    And if I wait 2 seconds
    Then "OutsideDimmer" should be in state "<dimmer_state>" within 5 seconds
    Examples:
      | other_switch_state | door_state | dimmer_state |
      | ON                 | OPEN       | 0            |
      | OFF                | OPEN       | 0            |
      | ON                 | CLOSED     | 0            |
      | OFF                | CLOSED     | 50           |


  @not_implemented
  Scenario Outline: Guards have access to event information
    Given a deployed rule:
      """
      rule 'Set OutsideDimmer to 50% if any switch in group Switches starting with Outside is switched On' do
        changed Switches.items, to: ON
        run { OutsideDimmer << 50 }
        only_if { |event| event.item.name.start_with? 'Outside' }
      end
      """
    When item "<switch>" state is changed to "<switch_state>"
    Then "OutsideDimmer" should be in state "<dimmer_state>" within 5 seconds
    Examples:
      | switch        | switch_state | dimmer_state |
      | LightSwitch   | ON           | 0            |
      | OutsideSwitch | ON           | 50           |


  Scenario Outline: Between guards accept strings to guard rule execution based on time of day
    Given a rule template:
      """
      rule 'Log an entry if started between 3:30:04 and midnight using strings' do
        on_start
        run { logger.info ("Between met expectation")}
        between <between>
      end
      """
    When I deploy the rule
    Then It <should> log "Between met expectation" within 15 seconds
    Examples:
      | between                                                                                           | should     |
      | '<%=(Time.now - (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'  | should     |
      | '<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (10*60)).strftime('%H:%M:%S')%>' | should not |



  @not_implemented
  Scenario: Between guards rule execution based on dates

