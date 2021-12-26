Feature:  guards
  Rule languages supports guards (only_if/not_if)


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

  Scenario Outline: only_if/not_if support arrays of items
    Given a deployed rule:
      """
      rule 'Set OutsideDimmer to 50% if LightSwtich turned on and OtherSwitch is also ON and Door is closed' do
        updated LightSwitch
        run { OutsideDimmer << 50 }
        <guard> [OtherSwitch, LightSwitch]
      end
      """
    When item "OtherSwitch" state is changed to "<other_switch_state>"
    And item "LightSwitch" state is changed to "<light_switch_state>"
    And if I wait 2 seconds
    Then "OutsideDimmer" should be in state "<dimmer_state>" within 5 seconds
    Examples:
      | other_switch_state | light_switch_state | dimmer_state | guard   |
      | ON                 | OFF                | 0            | only_if |
      | OFF                | OFF                | 0            | only_if |
      | ON                 | ON                 | 50           | only_if |
      | OFF                | ON                 | 0            | only_if |
      | OFF                | OFF                | 50           | not_if  |
      | ON                 | ON                 | 0            | not_if  |
      | OFF                | ON                 | 0            | not_if  |
      | ON                 | OFF                | 0            | not_if  |

  Scenario Outline: only_if and not_if raise an error if supplied objects that don't respond to 'truthy'?
    And a rule
      """
      Foo = Object.new
      begin
        rule 'turn  on light switch at start' do
          on_start
          changed LightSwitch, to: ON
          <guard>
        end
      rescue ArgumentError => e
        logger.error(e)
      end
      """
    When I deploy a rule with an error
    Then It should log "<log_line>" within 20 seconds
    Examples:
      | guard        | log_line                                           |
      | only_if Foo  | Object passed to only_if must respond_to 'truthy?' |
      | not_if  Foo  | Object passed to not_if must respond_to 'truthy?'  |


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


  Scenario Outline: Guards have access to event information
    Given a deployed rule:
      """
      rule 'Set OutsideDimmer to 50% if any switch in group Switches starting with Outside is switched On' do
        changed Switches.members, to: ON
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


  Scenario Outline: Guards have access to the main object's context
    Given a deployed rule:
      """
      def meth
        logger.info("Guard Context: #{self}") 
      end

      def meth2
        logger.info("Run Context: #{self}") 
      end

      rule 'Check guard context' do
        changed OutsideDimmer
        run { meth2 }
        <guard>
      end
      """
    When item "OutsideDimmer" state is changed to "50"
    Then It should log "Guard Context: main" within 5 seconds
    Examples:
    | guard                                     |
    | only_if { meth; false }                   |
    | not_if { meth; true }                     |



  Scenario Outline: Between guards accept a mix of string and time of day objects to guard rule execution based on time of day or day of month
    Given a rule template:
      """
      rule 'Log result of between guard' do
        on_start
        run { logger.info ("Between guard: true")}
        between <between>
        otherwise { logger.info ("Between guard: false")}
      end
      """
    When I deploy the rule
    Then It should log "Between guard: <result>" within 5 seconds
    Examples:
      | between                                                                                                | result   |
      | '<%=(Time.now - (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'       | true     |
      | '<%=(Time.now - (5*60)).strftime('%H:%M:%S')%>'..TimeOfDay.new(h: Time.now.hour, m: Time.now.min + 5)  | true     |
      | TimeOfDay.new(h: Time.now.hour, m: Time.now.min - 5)..'<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'  | true     |
      | '<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (10*60)).strftime('%H:%M:%S')%>'      | false    | 
      | '<%=Date.today.prev_day.strftime('%m-%d')%>'..'<%=Date.today.next_day.strftime('%m-%d')%>'             | true     |

  Scenario Outline: All item types should work in only_if/not_if guards
   Given items:
      | type    | name   | 
      | <type>  | Foo    | 
    Given a deployed rule:
      """
      Foo << <value> if <set_value>
      rule 'guard check' do
        run { logger.info "Guard: Allowed" }
        on_start
        <guard> Foo
        otherwise { logger.info "Guard: Denied" }
      end
      """
    When I deploy the rule
    Then It should log "Guard: <result>" within 5 seconds
    Examples:
      | type          | value                       | guard   | set_value | result   |
      | Switch        | X                           | only_if | false     | Denied   |
      | Switch        | X                           | not_if  | false     | Allowed  |
      | Switch        | ON                          | only_if | true      | Allowed  |
      | Switch        | OFF                         | only_if | true      | Denied   |
      | Number        | X                           | only_if | false     | Denied   |
      | Number        | 0                           | only_if | true      | Denied   |
      | Number        | 10                          | only_if | true      | Allowed  |
      | DateTime      | X                           | only_if | false     | Denied   |
      | DateTime      | "1970-01-01T00:00:00+00:00" | only_if | true      | Allowed  |
      | String        | OFF                         | only_if | false     | Denied   |
      | String        | ''                          | only_if | true      | Denied   |
      | String        | 'foo'                       | only_if | true      | Allowed  |
      | Color         | 'foo'                       | only_if | false     | Denied   |
      | Color         | '12,14,5'                   | only_if | true      | Allowed  |
      | Color         | '12,14,5'                   | only_if | true      | Allowed  |
      | Location      | '12,14'                     | only_if | false     | Denied   |
      | Location      | '12,14'                     | only_if | true      | Allowed  |
      | Player        | X                           | only_if | false     | Denied   |
      | Rollershutter | X                           | only_if | false     | Denied   |
      | Rollershutter | 40                          | only_if | true      | Allowed  |
      | Dimmer        | X                           | only_if | false     | Denied   |
      | Dimmer        | 0                           | only_if | true      | Denied   |
      | Dimmer        | 10                          | only_if | true      | Allowed  |
 
