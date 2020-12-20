Feature:  Rule languages supports groups

  Background:
    Given Clean OpenHAB with latest Ruby Libraries
    And items:
      | type   | name       | label           | state |
      | Dimmer | DimmerTest | Test Dimmer     | 45    |
      | Switch | SwitchTest | Test Switch     | OFF   |
      | Switch | SwitchTwo  | Test Switch Two | OFF   |

  Scenario: Can access items as an enumerable/array
    Given code in a rules file
      """
      logger.info("Item Count: #{items.count}")
      logger.info("Items: #{items.sort_by(&:label).map(&:label).join(', ')}")
      """
    When I deploy the rules file
    Then It should log 'Item Count: 3' within 5 seconds
    And It should log 'Items: Test Dimmer, Test Switch' within 5 seconds

  Scenario: Fetch Item by name
    Given code in a rules file
      """
      logger.info("Dimmer Name: #{items['DimmerTest'].name}")
      """
    When I deploy the rules file
    Then It should log 'Dimmer Name: DimmerTest' within 5 seconds

  Scenario: Dynamically adjust dimmer when corresponding switch is turned on
    Given a deployed rule:
      """
      rule 'Increase Related Dimmer Brightness when Switch is turned on' do
        changed SwitchTest, to: ON
        triggered { |item| items[item.name.gsub('Switch','Dimmer')].brighten(10) }
      end
      """
    When item "SwitchTest" state is changed to "ON"
    Then "DimmerTest" should be in state "55" within 5 seconds

  Scenario Outline: Send command to an item
    Given a deployed rule:
      """
      rule 'Increase Related Dimmer Brightness when Switch is turned on' do
        changed SwitchTest, to: ON
        run { <command> }
      end
      """
    When item "SwitchTest" state is changed to "ON"
    Then "SwitchTwo" should be in state "ON" within 5 seconds
    Examples:
      | command         |
      | SwitchTwo << ON |

  Scenario: id returns label if set or name if not
    Given items:
      | type   | name      | label       |
      | Dimmer | DimmerOne | Test Dimmer |
      | Dimmer | DimmerTwo |             |
    Given code in a rules file
      """
      logger.info "Dimmer One: #{DimmerOne.id}"
      logger.info "Dimmer Two: #{DimmerTwo.id}"
      """
    When I deploy the rules file
    Then It should log 'Dimmer One: Test Dimmer' within 5 seconds
    And It should log 'Dimmer Two: DimmerTwo' within 5 seconds

  Scenario: undef? returns true if item is in state UNDEF
    Given code in a rules file
      """
      SwitchTest.setState(UNDEF)
      logger.info("SwitchTest is UNDEF") if SwitchTest.undef?
      """
    When I deploy the rules file
    Then It should log 'SwitchTest is UNDEF' within 5 seconds

  Scenario: null? returns true if item is in state NULL
    Given code in a rules file
      """
      SwitchTest.setState(NULL)
      logger.info("SwitchTest is NULL") if SwitchTest.null?
      """
    When I deploy the rules file
    Then It should log 'SwitchTest is NULL' within 5 seconds

  Scenario: state? returns true if item is not in state NULL or UNDEF
    Given code in a rules file
      """
      SwitchTest.setState(NULL)
      DimmerTest.setState(UNDEF)
      [SwitchTest, DimmerTest, SwitchTwo].each do |item|
        logger.info("#{item.name} has a state") if item.state?
        logger.info("#{item.name} does not have a state") unless item.state?
      end
      """
    When I deploy the rules file
    Then It should log 'SwitchTwo has a state' within 5 seconds
    And It should log 'SwitchTest does not have a state' within 5 seconds
    And It should log 'DimmerTest does not have a state' within 5 seconds

  Scenario: state returns nil if item is in state NULL or UNDEF
    Given code in a rules file
      """
      SwitchTest.setState(NULL)
      DimmerTest.setState(UNDEF)
      [SwitchTest, DimmerTest, SwitchTwo].each do |item|
        logger.info("#{item.name} has a state") unless item.state.nil?
        logger.info("#{item.name} does not have a state") if item.state.nil?
      end
      """
    When I deploy the rules file
    Then It should log 'SwitchTwo has a state' within 5 seconds
    And It should log 'SwitchTest does not have a state' within 5 seconds
    And It should log 'DimmerTest does not have a state' within 5 seconds

  Scenario Outline: Item returns string representation of state value for to_s
    Given items:
      | type   | name | state   |
      | <type> | Test | <state> |
    Given code in a rules file
      """
      logger.info("Item: #{Test}")
      """
    When I deploy the rules file
    Then It should log 'Item: <state>' within 5 seconds
    Examples:
      | type    | state          |
      | String  | "Hello, World" |
      | Switch  | ON             |
      | Dimmer  | 50             |
      | Contact | OPEN           |
      | Number  | 90.6           |


  Scenario: Items in array work with array methods
    Given items:
      | type   | name            | state |
      | Number | Livingroom_Temp | 70    |
      | Number | Bedroom_Temp    | 50    |
    And code in a rules file
      """
      number_items = [Livingroom_Temp, Bedroom_Temp]
      logger.info("Max is #{number_items.max}")
      logger.info("Min is #{number_items.min}")
      """
    When I deploy the rules file
    Then It should log "Max is 70" within 5 seconds
    And It should log "Min is 50" within 5 seconds


  Scenario: Send update to an item
    Given a deployed rule:
      """
      rule 'Item Updated' do
        updated SwitchTest, to: OFF
        run { logger.info("SwitchTest Received Update") }
      end
      """
    And code in a rules file
      """
      SwitchTest.update OFF
      """
    When I deploy the rules file
    Then It should log "SwitchTest Received Update" within 5 seconds