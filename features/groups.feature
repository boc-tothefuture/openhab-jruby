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
      logger.info("Temperatures: #{House.all_members.sort_by(&:label).map(&:label).join(', ')}")
      """
    When I deploy the rules file
    Then It should log 'Total Temperatures: 3' within 5 seconds
    And It should log 'Temperatures: Bedroom temperature, Den temperature, Living Room temperature' within 5 seconds


  Scenario: Access to group data
    Given code in a rules file
      """
      logger.info("Group: #{Temperatures.name}")
      """
    When I deploy the rules file
    Then It should log 'Group: Temperatures' within 5 seconds


  Scenario: Ability to operate on the items in nested group using all_members and enumerable methods
    Given code in a rules file
      """
      logger.info("House Count: #{House.all_members.count}")
      logger.info("Items: #{House.all_members.sort_by(&:label).map(&:label).join(', ')}")
      """
    When I deploy the rules file
    Then It should log 'House Count: 3' within 5 seconds
    And It should log 'Items: Bedroom temperature, Den temperature, Living Room temperature' within 5 seconds

  Scenario: Access to sub groups using all_members(:groups)
    Given code in a rules file
      """
      logger.info("House Sub Groups: #{House.all_members(:groups).count}")
      logger.info("Groups: #{House.all_members(:groups).sort_by(&:id).map(&:id).join(', ')}")
      """
    When I deploy the rules file
    Then It should log 'House Sub Groups: 4' within 5 seconds
    And It should log 'Groups: GroundFloor, Livingroom, Sensors, Temperatures' within 5 seconds

  Scenario: Access to parent groups using groups method
    Given code in a rules file
      """
      logger.info("Parent Groups: #{Temperatures.groups.map(&:id).sort.join(', ')}")
      """
    When I deploy the rules file
    Then It should log 'Parent Groups: Sensors' within 5 seconds

  Scenario: Filter output of all_members with a block
    Given code in a rules file
      """
      logger.info(House.all_members { |item| /.*room.*/.match?(item.name) }.sort_by(&:name).map(&:name).join(', '))
      """
    When I deploy the rules file
    Then It should log ' Bedroom_Temp, Livingroom, Livingroom_Temp' within 5 seconds

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
        updated Temperatures.members
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

  Scenario: Groups work in case statements
    Given groups:
      | name         | type          | function | params       |
      | Switches     | Switch        | AND      | ON, OFF      |
      | Contacts     | Contact       | OR       | OPEN, CLOSED |
      | Shutters     | Rollershutter | AND      | UP, DOWN     |

    And items:
      | type          | name       | label       | state  | groups   |
      | Switch        | SwitchOne  | Switch One  | ON     | Switches |
      | Switch        | SwitchTwo  | Switch Two  | OFF    | Switches |
      | Contact       | ContactOne | Contact One | OPEN   | Contacts |
      | Contact       | ContactTwo | Contact Two | CLOSED | Contacts |
      | Rollershutter | ShutterOne | Shutter One | 0      | Shutters |
      | Rollershutter | ShutterTwo | Shutter Two | 50     | Shutters |

    And code in a rules file
      """
      case Contacts
      when OPEN then logger.info('At least one contact is OPEN')
      when CLOSED then logger.info('All contacts are CLOSED')
      end

      case Switches
      when ON then logger.info('All switches are ON')
      when OFF then logger.info('At least one switch is OFF')
      end

      case Shutters
      when UP then logger.info('All shutters are UP')
      when DOWN then logger.info('At least one shutter is not UP')
      end
      """
    When I deploy the rules file
    Then It should log "At least one contact is OPEN" within 5 seconds
    And It should log "At least one switch is OFF" within 5 seconds
    And It should log "At least one shutter is not UP" within 5 seconds

  Scenario: members on groups indicates to rules engine to trigger on changes to any members of the group
    Given a deployed rule:
      """
      rule 'group member updated' do
        updated Temperatures.members
        run do |event|
          logger.info("Group temperature updated")
        end
      end
      """
    When update state for item "Livingroom_Temp" to "65"
    Then It should log 'Group temperature updated' within 5 seconds

  Scenario: Can iterate group members
    Given code in a rules file:
      """
      logger.info("Ground Floor: #{GroundFloor.members.sort_by(&:name).map(&:name).join(', ')}")
      """
    When I deploy the rules file
    Then It should log 'Ground Floor: Bedroom_Temp, Den_Temp, Livingroom' within 5 seconds

  Scenario: Changes to groups is visible to running rules
    Given code in a rules file:
      """
      rule 'test' do
        on_start
        run { logger.info(Temperatures.sort_by(&:name).map(&:name).join(', ')) }
        delay 10.seconds
        run { logger.info(Temperatures.sort_by(&:name).map(&:name).join(', ')) }
      end
      """
    When I deploy the rules file
    Then It should log "Bedroom_Temp, Den_Temp, Livingroom_Temp" within 5 seconds
    But if I wait 5 seconds
    And I add items:
      | type   | name            | label                   | state | groups       |
      | Number | Livingroom_Temp | Living Room temperature | 70    |              |
      | Number | Kitchen_Temp    | Kitchen     temperature | 60    | Temperatures |
    Then It should log "Bedroom_Temp, Den_Temp, Kitchen_Temp" within 10 seconds

  Scenario: Changing of Group type updates methods
    Given groups:
      | name     | type   |
      | Switches | Switch |

    And code in a rules file:
      """
      rule 'test' do
        on_start
        run { logger.info(Switches.respond_to?(:on?)) }
        delay 10.seconds
        run { logger.info(Switches.respond_to?(:on?)) }
      end
      """
    When I deploy the rules file
    Then It should log "true" within 5 seconds
    But if I wait 5 seconds
    And groups:
      | name     | type    |
      | Switches | Contact |
    Then It should log "false" within 10 seconds
