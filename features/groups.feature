Feature:  groups
  Rule languages supports groups

  Background:
    Given Clean OpenHAB with latest Ruby Libraries
    And groups:
      | name         | group       |
      | House        |             |
      | GroundFloor  | House       |
      | Livingroom   | GroundFloor |
      | Sensors      | House       |
      | Temperatures | Sensors     |
    And items:
      | type   | name            | label                   | state | groups                    |
      | Number | Livingroom_Temp | Living Room temperature | 70    | Livingroom, Temperatures  |
      | Number | Bedroom_Temp    | Bedroom temperature     | 50    | GroundFloor, Temperatures |
      | Number | Den_Temp        | Den temperature         | 30    | GroundFloor, Temperatures |


  Scenario: Ability to operate on the items in a group using enumerable methods
    Given code in a rules file
      """
      logger.info("Total Temperatures: #{Temperatures.count}")
      logger.info("Temperatures: #{House.sort_by(&:label).map(&:label).join(', ')}")
      """
    When I deploy the rules file
    Then It should log 'Total Temperatures: 3' within 5 seconds
    And It should log 'Temperatures: Bedroom temperature, Den temperature, Living Room temperature' within 5 seconds


  Scenario: Access to group data via group method
    Given code in a rules file
      """
      logger.info("Group: #{Temperatures.group.name}")
      """
    When I deploy the rules file
    Then It should log 'Group: Temperatures' within 5 seconds


  Scenario: Ability to operate on the items in nested group using enumerable methods
    Given code in a rules file
      """
      logger.info("House Count: #{House.count}")
      logger.info("Items: #{House.sort_by(&:label).map(&:label).join(', ')}")
      """
    When I deploy the rules file
    Then It should log 'House Count: 3' within 5 seconds
    And It should log 'Items: Bedroom temperature, Den temperature, Living Room temperature' within 5 seconds

  Scenario: Access to sub groups using the `groups` method
    Given code in a rules file
      """
      logger.info("House Sub Groups: #{House.groups.count}")
      logger.info("Groups: #{House.groups.sort_by(&:id).map(&:id).join(', ')}")
      """
    When I deploy the rules file
    Then It should log 'House Sub Groups: 2' within 5 seconds
    And It should log 'Groups: GroundFloor, Sensors' within 5 seconds

  Scenario: Fetch Group by name
    And code in a rules file
      """
      logger.info("Sensors Group: #{groups['Sensors'].name}")
      """
    When I deploy the rules file
    Then It should log 'Sensors Group: Sensors' within 5 seconds


  Scenario: Groups have enumerable based math functions
    Given code in a rules file
      """
      logger.info("Max is #{Temperatures.max}")
      logger.info("Min is #{Temperatures.min}")
      """
    When I deploy the rules file
    Then It should log "Max is 70" within 5 seconds
    And It should log "Min is 30" within 5 seconds

  Scenario: Group update trigger has event.item in run block
    Given code in a rules file
      """
      rule 'group member updated' do
        updated Temperatures.items
        run do |event|
          logger.info("event.item is #{event.item.name}")
        end
      end

      rule 'update a group member' do
        on_start
        run { Livingroom_Temp.update 65 }
      end
      """
    When I deploy the rules file
    Then It should log 'event.item is Livingroom_Temp' within 5 seconds

  Scenario Outline: Commands sent to a group are propagated to the group items
    Given code in a rules file
      """
        GroundFloor.<method> <value>
      """
    When I deploy the rules file
    Then "Bedroom_Temp" should be in state "<value>" within 5 seconds
    And "Den_Temp" should be in state "<value>" within 5 seconds
    Examples:
      | method  | value |
      | <<      | 55    |
      | command | 60    |

