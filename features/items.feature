Feature:  Rule languages supports groups

  Background:
    Given Clean OpenHAB with latest Ruby Libraries
    And items:
      | type   | name       | label       | state |
      | Dimmer | DimmerTest | Test Dimmer | 45    |
      | Switch | SwitchTest | Test Switch | OFF   |

  Scenario: Can access items as an enumerable/array
    And code in a rules file
      """
      logger.info("Item Count: #{items.count}")
      logger.info("Items: #{items.sort_by{|item| item.name}.join(', ')}")
      """
    When I deploy the rules file
    Then It should log 'Item Count: 2' within 5 seconds
    And It should log 'Items: Test Dimmer, Test Switch' within 5 seconds

  Scenario: Fetch Item by name
    And code in a rules file
      """
      logger.info("Dimmer Name: #{items['DimmerTest'].name}")
      """
    When I deploy the rules file
    Then It should log 'Dimmer Name: DimmerTest' within 5 seconds

  Scenario: Dynamically adjust dimmer when corresponding switch is turned on
    And a rule
      """
      rule 'Increase Related Dimmer Brightness when Switch is turned on' do
        changed SwitchTest, to: ON
        triggered { |item| items[item.name.gsub('Switch','Dimmer')].brighten(10) }
      end
      """
    When I deploy the rule
    And item "SwitchTest" state is changed to "ON"
    Then "DimmerTest" should be in state "55" within 5 seconds

