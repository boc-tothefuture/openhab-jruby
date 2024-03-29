Feature:  items
  Rule languages supports items

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

  Scenario: Send command to an item
    Given a deployed rule:
      """
      rule 'Increase Related Dimmer Brightness when Switch is turned on' do
        changed SwitchTest, to: ON
        run { SwitchTwo << ON }
      end
      """
    When item "SwitchTest" state is changed to "ON"
    Then "SwitchTwo" should be in state "ON" within 5 seconds

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
      | Number  | NULL           |
      | Number  | UNDEF          |


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

  Scenario: Check for item existence
    Given code in a rules file
      """
      logger.info("DimmerTest include? #{items.include? 'DimmerTest'}")
      logger.info("SimmerTest include? #{items.include? 'SimmerTest'}")
      logger.info("SimmerTest item nil? #{items['SimmerTest'].nil?}")
      """
    When I deploy the rules file
    Then It should log 'DimmerTest include? true' within 5 seconds
    And It should log 'SimmerTest include? false' within 5 seconds
    And It should log 'SimmerTest item nil? true' within 5 seconds

  Scenario: Verify class of item
    Given items:
      | type   | name    | state |
      | Number | Number1 | 1     |
    And code in a rules file
      """
      logger.info("Number1 class is a NumberItem? #{Number1.class == OpenHAB::DSL::Items::NumberItem}")
      logger.info("items['Number1'] class is a NumberItem? #{items['Number1'].class == OpenHAB::DSL::Items::NumberItem}")
      """
    When I deploy the rules file
    Then It should log "Number1 class is a NumberItem? true" within 5 seconds
    And It should log "items['Number1'] class is a NumberItem? true" within 5 seconds

  Scenario: Verify items can access groups
    Given groups:
      | name         |
      | Numbers      |
      | EvenNumbers  |
      | PrimeNumbers |
    Given items:
      | type   | name    | groups                |
      | Number | Number3 | Numbers, PrimeNumbers |
    And code in a rules file
      """
      logger.info("Number3 is in groups #{Number3.groups.map(&:name).join(', ')}")
      """
    When I deploy the rules file
    Then It should log "Number3 is in groups Numbers, PrimeNumbers" within 5 seconds

  Scenario: Dangling group references are ignored
    Given groups:
      | name    |
      | Numbers |
    Given items:
      | type   | name    | groups                |
      | Number | Number3 | Numbers, PrimeNumbers |
    And code in a rules file
      """
      logger.info("Number3 is in groups #{Number3.groups.map(&:name).join(', ')}$")
      """
    When I deploy the rules file
    Then It should log "Number3 is in groups Numbers$" within 5 seconds

  Scenario Outline: Items can be used as hash keys
    # Ref: https://github.com/boc-tothefuture/openhab-jruby/issues/252
    Given items:
      | type   | name   |
      | <type> | <name> |
    And code in a rules file
      """
      ITEMS_HASH = { <name> => "I'm <name>" }
      logger.info("#{ITEMS_HASH[<name>]}")
      logger.info("<name>.hash == <name>.hash: #{<name>.hash == <name>.hash}")
      logger.info("<name>.eql?(<name>): #{<name>.eql?(<name>)}")
      """
    When I deploy the rules file
    Then It should log "I'm <name>" within 5 seconds
    And It should log "<name>.hash == <name>.hash: true" within 5 seconds
    And It should log "<name>.eql?(<name>): true" within 5 seconds
    Examples:
      | type   | name    |
      | Number | Number1 |
      | String | String1 |
      | Player | Player1 |

  Scenario: Item returns nil for an unlinked item
    Given items:
      | type   | name    |
      | Number | Number1 |
    And code in a rules file
      """
      logger.info("No thing: #{Number1.thing.nil?}")
      """
    When I deploy the rules file
    Then It should log "No thing: true" within 5 seconds

  Scenario: Item returns its linked thing
    Given feature 'openhab-binding-astro' installed
    And items:
      | type   | name      |
      | String | PhaseName |
    And things:
      | id   | thing_uid | label          | config                | status |
      | home | astro:sun | Astro Sun Data | {"geolocation":"0,0"} | enable |
    And linked:
      | item      | channel                   |
      | PhaseName | astro:sun:home:phase#name |
    And code in a rules file
      """
      logger.info("Thing: #{PhaseName.thing.uid}")
      """
    When I deploy the rules file
    Then It should log "Thing: astro:sun:home" within 5 seconds

  Scenario: Item returns all its linked things
    Given feature 'openhab-binding-astro' installed
    And items:
      | type   | name          |
      | String | TooManyThings |
    And things:
      | id   | thing_uid  | label           | config                | status |
      | home | astro:sun  | Astro Sun Data  | {"geolocation":"0,0"} | enable |
      | home | astro:moon | Astro Moon Data | {"geolocation":"0,0"} | enable |
    And linked:
      | item          | channel                    |
      | TooManyThings | astro:sun:home:phase#name  |
      | TooManyThings | astro:moon:home:phase#name |
    And code in a rules file
      """
      logger.info("Thing: #{TooManyThings.things.map(&:uid).map(&:to_s).sort.join(',')}")
      """
    When I deploy the rules file
    Then It should log "Thing: astro:moon:home,astro:sun:home" within 5 seconds

  Scenario: Referenced items always access latest item instance
    Given items:
      | type   | name      | label  |
      | String | FooString | foo    |
      | Switch | MySwitch  | switch |
    And a rule:
      """
      h = { foo: FooString }
      rule 'check reference' do
        on_start
        changed MySwitch
        run { logger.info("Label: #{h[:foo].label}") }
      end
      """
    When I deploy the rule
    Then It should log "Label: foo" within 5 seconds
    But If items:
      | type   | name      | label |
      | String | FooString | bar   |
    And item 'MySwitch' state is changed to 'ON'
    Then It should log "Label: bar" within 5 seconds

  Scenario: Item objects can be compared in a case statement
    Given a rule:
      """
      logger.info case SwitchTwo.item
                  when DimmerTest then 'Matched DimmerTest'
                  when SwitchTest then 'Matched SwitchTest'
                  when SwitchTwo then 'Matched SwitchTwo'
                  end
      """
    When item 'DimmerTest' state is changed to '0'
    And I deploy the rule
    Then It should log "Matched SwitchTwo" within 5 seconds

  Scenario: Items matches array#include?
    Given a rule:
      """
      logger.info("SwitchTwo in array? #{[DimmerTest, SwitchTwo].include?(SwitchTwo.item)}")
      logger.info("DimmerTest in array? #{[SwitchTwo, SwitchTest].include?(DimmerTest.item)}")
      logger.info("SwitchTest in array? #{[DimmerTest, SwitchTwo].include?(SwitchTest.item)}")
      """
    When item 'DimmerTest' state is changed to '0'
    And I deploy the rule
    Then It should log "SwitchTwo in array? true" within 5 seconds
    And It should log "DimmerTest in array? false" within 5 seconds
    And It should log "SwitchTest in array? false" within 5 seconds

  Scenario: Items matches hash#key?
    Given a rule:
      """
      logger.info("SwitchTwo in hash? #{{DimmerTest => true, SwitchTwo => true}.key?(SwitchTwo)}")
      logger.info("SwitchTwo.item in hash? #{{DimmerTest => true, SwitchTwo => true}.key?(SwitchTwo.item)}")
      logger.info("DimmerTest in hash? #{{SwitchTwo => true, SwitchTest => true}.key?(DimmerTest)}")
      logger.info("SwitchTest in hash? #{{DimmerTest => true, SwitchTwo => true}.key?(SwitchTest)}")
      """
    When item 'DimmerTest' state is changed to '0'
    And I deploy the rule
    Then It should log "SwitchTwo in hash? true" within 5 seconds
    And It should log "SwitchTwo.item in hash? true" within 5 seconds
    And It should log "DimmerTest in hash? false" within 5 seconds
    And It should log "SwitchTest in hash? false" within 5 seconds

  Scenario: Items matches hash#value?
    Given a rule:
      """
      logger.info("SwitchTwo in value? #{{a: DimmerTest, b: SwitchTwo}.value?(SwitchTwo.item)}")
      logger.info("DimmerTest in value? #{{a: SwitchTwo, b: SwitchTest}.value?(DimmerTest.item)}")
      logger.info("SwitchTest in value? #{{a: DimmerTest, b: SwitchTwo}.value?(SwitchTest.item)}")
      """
    When item 'DimmerTest' state is changed to '0'
    And I deploy the rule
    Then It should log "SwitchTwo in value? true" within 5 seconds
    And It should log "DimmerTest in value? false" within 5 seconds
    And It should log "SwitchTest in value? false" within 5 seconds

  Scenario Outline: Direct comparison of Items
    Given items:
      | type   | name               | state |
      | String | NonNullStringItem1 | hi    |
      | String | NullStringItem1    | NULL  |
    And a rule:
      """
      logger.info("<left> == <right>: #{<left> == <right>}")
      """
    When I deploy the rule
    Then It should log "<left> == <right>: <result>" within 5 seconds
    Examples: State comparisons
      | left      | right      | result |
      | SwitchTwo | SwitchTest | true   |
    Examples: Different item objects comparisons
      | left               | right                | result |
      | SwitchTwo.item     | SwitchTest.item      | false  |
      | SwitchTwo.item     | SwitchTest           | false  |
      | NonNullStringItem1 | NullStringItem1.item | false  |
    Examples: Same item object comparisons
      | left           | right                   | result |
      | SwitchTwo.item | items['SwitchTwo'].item | true   |
      | SwitchTwo      | items['SwitchTwo'].item | true   |
      | SwitchTwo.item | items['SwitchTwo']      | true   |

  Scenario: GroupItem grep can use Item.item
    Given group "Switches"
    And items:
      | type   | name    | group    | state |
      | Switch | Switch1 | Switches | OFF   |
      | Switch | Switch2 | Switches | OFF   |
    And a rule:
      """
      logger.info "grep result1: #{Switches.grep(Switch1.item).first.name}"
      logger.info "grep result2: #{Switches.grep(Switch2.item).first.name}"
      logger.info "grep result3: #{Switches.grep(Switch1).first.name}"
      logger.info "grep result4: #{Switches.grep(Switch2).first.name}"
      """
    When I deploy the rule
    Then It should log "grep result1: Switch1" within 5 seconds
    And It should log "grep result2: Switch2" within 5 seconds
    And It should log "grep result3: Switch1" within 5 seconds
    And It should log "grep result4: Switch2" within 5 seconds

