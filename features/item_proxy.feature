Feature:  item_proxy
  Rule languages supports item proxy

  Background:
    Given Clean OpenHAB with latest Ruby Libraries
    And items:
      | type   | name       | label           | state |
      | Dimmer | DimmerTest | Test Dimmer     | 45    |
      | Switch | SwitchTest | Test Switch     | OFF   |
      | Switch | SwitchTwo  | Test Switch Two | OFF   |

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
