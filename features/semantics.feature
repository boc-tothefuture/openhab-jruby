Feature: semantics
  Rule languages supports openHAB's semantics model

  Background:
    Given Clean OpenHAB with latest Ruby Libraries
    And groups:
      | name                   | groups                | tags                 |
      | gMyGroup               |                       |                      |
      | gOutdoor               |                       | Outdoor              |
      | gPatio                 | gOutdoor              | Patio                |
      | Patio_Light_Bulb       | gPatio                | Lightbulb            |
      | gIndoor                |                       | Indoor               |
      | gLivingRoom            | gIndoor               | LivingRoom           |
      | LivingRoom_Light1_Bulb | gLivingRoom, gMyGroup | Lightbulb            |
      | LivingRoom_Light2_Bulb | gLivingRoom           | Lightbulb, CustomTag |
    And items:
      | type   | name                         | groups                           | tags                      |
      | Switch | NoSemantic                   |                                  |                           |
      | Dimmer | Patio_Light_Brightness       | Patio_Light_Bulb                 | Control,Level             |
      | Color  | Patio_Light_Color            | Patio_Light_Bulb                 | Control,Light             |
      | Switch | Patio_Motion                 | gPatio                           | MotionDetector, CustomTag |
      | Switch | Patio_Point                  | gPatio                           | Control                   |
      | Dimmer | LivingRoom_Light1_Brightness | LivingRoom_Light1_Bulb           | Control,Level             |
      | Color  | LivingRoom_Light1_Color      | LivingRoom_Light1_Bulb           | Control,Light             |
      | Switch | LivingRoom_Light1_Custom     | LivingRoom_Light1_Bulb, gMyGroup |                           |
      | Dimmer | LivingRoom_Light2_Brightness | LivingRoom_Light2_Bulb           | Control,Level             |
      | Color  | LivingRoom_Light2_Color      | LivingRoom_Light2_Bulb           | Control,Light             |
      | Switch | LivingRoom_Motion            | gLivingRoom                      | MotionDetector            |

  Scenario Outline: Items have semantics methods
    Given code in a rules file
      """
      begin
        logger.info("Item <item>.<method>: #{<item>.<method>}")
      rescue => e
        logger.error("Item <item>.<method>: Exception caught: #{e.message}")
      end
      """
    When I deploy the rules file
    Then It should log 'Item <item>.<method>: <result>' within 5 seconds
    Examples: Semantic predicates
      | item             | method     | result |
      | gIndoor          | location?  | true   |
      | gIndoor          | equipment? | false  |
      | gIndoor          | point?     | false  |
      | NoSemantic       | semantic?  | false  |
      | Patio_Light_Bulb | semantic?  | true   |
      | Patio_Light_Bulb | equipment? | true   |
      | Patio_Motion     | equipment? | true   |
    Examples: Semantic types
      | item                   | method                                 | result |
      | Patio_Light_Bulb       | location_type == Semantics::Patio      | true   |
      | Patio_Light_Bulb       | equipment_type == Semantics::Lightbulb | true   |
      | Patio_Light_Brightness | point_type == Semantics::Control       | true   |
      | Patio_Light_Brightness | property_type == Semantics::Level      | true   |
      | Patio_Light_Brightness | equipment_type == Semantics::Lightbulb | true   |
      | Patio_Light_Brightness | semantic_type == Semantics::Control    | true   |
    Examples: Related semantic items
      | item                   | method         | result           |
      | Patio_Light_Bulb       | location.name  | gPatio           |
      | Patio_Light_Brightness | location.name  | gPatio           |
      | Patio_Light_Brightness | equipment.name | Patio_Light_Bulb |
    Examples: Sibling points of a point
      | item                   | method             | result                |
      | Patio_Light_Brightness | points.map(&:name) | ["Patio_Light_Color"] |
    Examples: Points of an equipment
      | item             | method                                                   | result                                          |
      | Patio_Light_Bulb | points.map(&:name).sort                                  | ["Patio_Light_Brightness", "Patio_Light_Color"] |
      | Patio_Light_Bulb | points(Semantics::Light).map(&:name)                     | ["Patio_Light_Color"]                           |
      | Patio_Light_Bulb | points(Semantics::Level).map(&:name)                     | ["Patio_Light_Brightness"]                      |
      | Patio_Light_Bulb | points(Semantics::Level, Semantics::Control).map(&:name) | ["Patio_Light_Brightness"]                      |
    Examples: Points of a location
      | item   | method             | result          |
      | gPatio | points.map(&:name) | ["Patio_Point"] |
    Examples: #points with invalid arguments
      | item             | method                                                        | result            |
      | Patio_Light_Bulb | points(Semantics::Level, Semantics::Indoor)                   | Exception caught: |
      | Patio_Light_Bulb | points(Semantics::Lightbulb)                                  | Exception caught: |
      | Patio_Light_Bulb | points(Semantics::Indoor)                                     | Exception caught: |
      | Patio_Light_Bulb | points(Semantics::Level, Semantics::Light)                    | Exception caught: |
      | Patio_Light_Bulb | points(Semantics::Switch, Semantics::Control)                 | Exception caught: |
      | Patio_Light_Bulb | points(Semantics::Switch, Semantics::Light, Semantics::Level) | Exception caught: |

  Scenario: points for a location does not return points in sublocations and equipments
    Given groups:
      | name               | groups   | tags      |
      | Outdoor_Light_Bulb | gOutdoor | Lightbulb |
    And items:
      | type   | name                 | groups             | tags           |
      | Switch | Outdoor_Light_Switch | Outdoor_Light_Bulb | Control, Power |
      | Switch | Outdoor_Point        | gOutdoor           | Control        |
    And code in a rules file:
      """
      logger.info gOutdoor.points.map(&:name).sort
      """
    When I deploy the rules file
    Then It should log '["Outdoor_Point"]' within 5 seconds

  Scenario Outline: Enumerable has semantics methods
    Given code in a rules file
      """
      begin
        logger.info(%Q[Item <item>.<method>: #{<item>.<method>}])
      rescue => e
        logger.error(%Q[Item <item>.<method>: Exception caught: #{e.message}])
      end
      """
    When I deploy the rules file
    Then It should log 'Item <item>.<method>: <result>' within 5 seconds
    Examples: Enumerable methods
      | item        | method                                               | result                                               |
      | gPatio      | equipments.map(&:name).sort                          | ["Patio_Light_Bulb", "Patio_Motion"]                 |
      | gIndoor     | sublocations.map(&:name).sort                        | ["gLivingRoom"]                                      |
      | gIndoor     | sublocations(Semantics::Room).map(&:name).sort       | ["gLivingRoom"]                                      |
      | gIndoor     | sublocations(Semantics::LivingRoom).map(&:name).sort | ["gLivingRoom"]                                      |
      | gIndoor     | sublocations(Semantics::FamilyRoom).map(&:name).sort | []                                                   |
      | gIndoor     | sublocations(Semantics::Light).map(&:name).sort      | Exception caught:                                    |
      | items       | tagged("CustomTag").map(&:name).sort                 | ["LivingRoom_Light2_Bulb", "Patio_Motion"]           |
      | gLivingRoom | tagged("Lightbulb").map(&:name).sort                 | ["LivingRoom_Light1_Bulb", "LivingRoom_Light2_Bulb"] |
      | gLivingRoom | not_tagged("Lightbulb").map(&:name).sort             | ["LivingRoom_Motion"]                                |
      | gLivingRoom | members.member_of(gMyGroup).map(&:name).sort         | ["LivingRoom_Light1_Bulb"]                           |
      | gLivingRoom | members.not_member_of(gMyGroup).map(&:name).sort     | ["LivingRoom_Light2_Bulb", "LivingRoom_Motion"]      |
    Examples: Chaining methods
      | item              | method                                                                | result                     |
      | LivingRoom_Motion | location.not_member_of(gMyGroup).tagged("CustomTag").map(&:name).sort | ["LivingRoom_Light2_Bulb"] |
      | LivingRoom_Motion | location.equipments.tagged("CustomTag").map(&:name).sort              | ["LivingRoom_Light2_Bulb"] |
    Examples: Enumerable#members
      | item                   | method                                       | result                       |
      | gLivingRoom.equipments | members.member_of(gMyGroup).map(&:name).sort | ["LivingRoom_Light1_Custom"] |

  Scenario Outline: Commands can be given to Enumerable
    Given code in a rules file
      """
      rule 'command' do
        received_command <item>, attach: 'command'
        updated <item>, attach: 'update'
        run do |event|
          value = event.respond_to?(:command) ? event.command : event.state
          logger.warn "Item #{event.item.name} received #{event.attachment} #{value}"
        end
      end

      [<item>].<command>(<value>)
      """
    When I deploy the rules file
    Then It should log "Item <item> received <command> <value>" within 5 seconds
    Examples:
      | item                         | command | value |
      | LivingRoom_Light1_Brightness | command | ON    |
      | LivingRoom_Light1_Brightness | update  | ON    |

  Scenario Outline: Enumerable supports points
    Given code in a rules file
      """
      begin
        points = <item>.equipments
                       .members
                       .points(<args>)
                       .map(&:name)
                       .sort

        logger.info("Item points(<args>): #{points}")
      rescue => e
        logger.error("Item points(<args>): Exception caught: #{e.message}")
      end
      """
    When I deploy the rules file
    Then It should log 'Item points(<args>): <result>' within 5 seconds
    Examples: Valid arguments
      | item   | args                                 | result                                          |
      | gPatio |                                      | ["Patio_Light_Brightness", "Patio_Light_Color"] |
      | gPatio | Semantics::Control                   | ["Patio_Light_Brightness", "Patio_Light_Color"] |
      | gPatio | Semantics::Light                     | ["Patio_Light_Color"]                           |
      | gPatio | Semantics::Light, Semantics::Control | ["Patio_Light_Color"]                           |
    Examples: Invalid arguments
      | item   | args                                  | result            |
      | gPatio | Semantics::Light, Semantics::Level    | Exception caught: |
      | gPatio | Semantics::Room                       | Exception caught: |
      | gPatio | Semantics::Control, Semantics::Switch | Exception caught: |

  Scenario: Support GroupItem as a Point
    Given groups:
      | name         | groups       | tags      |
      | My_Equipment | gIndoor      | Lightbulb |
      | GroupPoint   | My_Equipment | Switch    |
    And items:
      | type   | name       | groups       | tags           |
      | Dimmer | Brightness | My_Equipment | Control, Level |
    And code in a rules file:
      """
      logger.info  gIndoor.equipments
                          .members
                          .points
                          .map(&:name)
                          .sort
                          .to_s
      """
    When I deploy the rules file
    Then It should log '["Brightness", "GroupPoint"]' within 5 seconds

  Scenario Outline: GroupItem as a Point can find its siblings
    Given groups:
      | name         | groups       | tags      |
      | My_Equipment | gIndoor      | Lightbulb |
      | GroupPoint   | My_Equipment | Switch    |
    And items:
      | type   | name       | groups       | tags            |
      | Dimmer | Brightness | My_Equipment | Control, Level  |
      | Switch | MySwitch   | My_Equipment | Control, Switch |
    And code in a rules file:
      """
      logger.info  <item>.points.map(&:name).sort
      """
    When I deploy the rules file
    Then It should log '<siblings>' within 5 seconds
    Examples:
      | item       | siblings                   |
      | GroupPoint | ["Brightness", "MySwitch"] |
      | Brightness | ["GroupPoint", "MySwitch"] |

  Scenario: Support Non-group Equipment
    Given groups:
      | name            | groups  | tags      |
      | Group_Equipment | gIndoor | Lightbulb |
    And items:
      | type   | name               | groups          | tags           |
      | Switch | NonGroup_Equipment | gIndoor         | Lightbulb      |
      | Dimmer | Brightness         | Group_Equipment | Control, Level |
    And code in a rules file:
      """
      logger.info  gIndoor.equipments
                          .map(&:name)
                          .sort
                          .to_s
      """
    When I deploy the rules file
    Then It should log '["Group_Equipment", "NonGroup_Equipment"]' within 5 seconds

  Scenario: Get sub-equipment (equipment that belong to another equipment)
    Given groups:
      | name         | groups           | tags      |
      | SubEquipment | Patio_Light_Bulb | Lightbulb |
    And code in a rules file:
      """
      logger.info gPatio.equipments(Semantics::Lightbulb).members.equipments.map(&:name)
      """
    When I deploy the rules file
    Then It should log '["SubEquipment"]' within 5 seconds



