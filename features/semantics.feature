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
      | type   | name                         | groups                 | tags                      |
      | Switch | NoSemantic                   |                        |                           |
      | Dimmer | Patio_Light_Brightness       | Patio_Light_Bulb       | Control,Level             |
      | Color  | Patio_Light_Color            | Patio_Light_Bulb       | Control,Light             |
      | Switch | Patio_Motion                 | gPatio                 | MotionDetector, CustomTag |
      | Dimmer | LivingRoom_Light1_Brightness | LivingRoom_Light1_Bulb | Control,Level             |
      | Color  | LivingRoom_Light1_Color      | LivingRoom_Light1_Bulb | Control,Light             |
      | Dimmer | LivingRoom_Light2_Brightness | LivingRoom_Light2_Bulb | Control,Level             |
      | Color  | LivingRoom_Light2_Color      | LivingRoom_Light2_Bulb | Control,Light             |
      | Switch | LivingRoom_Motion            | gLivingRoom            | MotionDetector            |

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
    Examples: Valid values
      | item                   | method                                                  | result                                          |
      | gIndoor                | location?                                               | true                                            |
      | gIndoor                | equipment?                                              | false                                           |
      | gIndoor                | point?                                                  | false                                           |
      | NoSemantic             | semantic?                                               | false                                           |
      | Patio_Light_Bulb       | semantic?                                               | true                                            |
      | Patio_Light_Bulb       | equipment?                                              | true                                            |
      | Patio_Motion           | equipment?                                              | true                                            |
      | Patio_Light_Bulb       | location.name                                           | gPatio                                          |
      | Patio_Light_Bulb       | location_type == Semantics::Patio                       | true                                            |
      | Patio_Light_Bulb       | equipment_type == Semantics::Lightbulb                  | true                                            |
      | Patio_Light_Brightness | point_type == Semantics::Control                        | true                                            |
      | Patio_Light_Brightness | property_type == Semantics::Level                       | true                                            |
      | Patio_Light_Brightness | equipment.name                                          | Patio_Light_Bulb                                |
      | Patio_Light_Brightness | equipment_type == Semantics::Lightbulb                  | true                                            |
      | Patio_Light_Brightness | semantic_type == Semantics::Control                     | true                                            |
      | Patio_Light_Brightness | points.map(&:name)                                      | ["Patio_Light_Color"]                           |
      | Patio_Light_Bulb       | points.map(&:name).sort                                 | ["Patio_Light_Brightness", "Patio_Light_Color"] |
      | Patio_Light_Bulb       | points(Semantics::Light).first.name                     | Patio_Light_Color                               |
      | Patio_Light_Bulb       | points(Semantics::Level).first.name                     | Patio_Light_Brightness                          |
      | Patio_Light_Bulb       | points(Semantics::Level, Semantics::Control).first.name | Patio_Light_Brightness                          |
    Examples: #points with invalid arguments
      | item             | method                                                        | result            |
      | Patio_Light_Bulb | points(Semantics::Level, Semantics::Indoor)                   | Exception caught: |
      | Patio_Light_Bulb | points(Semantics::Lightbulb)                                  | Exception caught: |
      | Patio_Light_Bulb | points(Semantics::Indoor)                                     | Exception caught: |
      | Patio_Light_Bulb | points(Semantics::Level, Semantics::Light)                    | Exception caught: |
      | Patio_Light_Bulb | points(Semantics::Switch, Semantics::Control)                 | Exception caught: |
      | Patio_Light_Bulb | points(Semantics::Switch, Semantics::Light, Semantics::Level) | Exception caught: |

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

  Scenario Outline: Enumerable supports points
    Given code in a rules file
      """
      begin
        points = <item>.equipments
                       .flat_map { |e| e.respond_to?(:members) ? e.members : e }
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


