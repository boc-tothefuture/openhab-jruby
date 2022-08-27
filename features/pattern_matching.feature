Feature: semantics
  Rule languages supports openHAB's semantics model

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario Outline: Pattern matching work with base item properties
    Given feature 'openhab-binding-astro' installed
    And things:
      | id   | thing_uid | label          | config                | status |
      | home | astro:sun | Astro Sun Data | {"geolocation":"0,0"} | enable |
    Given groups:
      | name         |
      | Patio_Lights |
    And items:
      | type   | name          | groups       | tags     | label | state |
      | Switch | Patio_Light   | Patio_Lights | foo, bar | baz   | ON    |
      | Number | Sun_Elevation |              |          |       |       |
    And linked:
      | item          | channel                           |
      | Sun_Elevation | astro:sun:home:position#elevation |
    And code in a rules file
      """
        astro_thing = things['astro:sun:home']
        group = groups['Patio_Lights']
        logger.debug(group)
        #Patio_Light.deconstruct_keys(nil).each { |key, value| logger.debug("#{key}=#{value}")}
        items => [*, { <pattern> } => matched, *]
        logger.debug("Matched #{matched.name}")
      """
    When I deploy the rules file
    Then It should log 'Matched <item_name>' within 5 seconds
    Examples: Basic patterns
      | pattern                       | item_name     |
      | name: "Patio_Light"           | Patio_Light   |
      | name: /Light$/                | Patio_Light   |
      | id: "baz"                     | Patio_Light   |
      | label: "baz"                  | Patio_Light   |
      | state: ON                     | Patio_Light   |
      | type: SwitchItem              | Patio_Light   |
      | type_name: "Switch"           | Patio_Light   |
      | tags: { bar: true}            | Patio_Light   |
      | tags: { bar: true, foo: true} | Patio_Light   |
      | tags: { foo: true}            | Patio_Light   |
      | thing: ^astro_thing           | Sun_Elevation |
      | groups: [^group]              | Patio_Light   |
  #  | things: [^astro_thing] | Sun_Elevation | # I don't know why this doesn't currenty work


  Scenario Outline: Pattern matching work with item semantics
    Given groups:
      | name             | groups   | tags      |
      | Patio_Light_Bulb | gPatio   | Lightbulb |
      | gOutdoor         |          | Outdoor   |
      | gPatio           | gOutdoor | Patio     |
      | Patio_Light_Bulb | gPatio   | Lightbulb |
    And items:
      | type  | name              | groups           | tags          |
      | Color | Patio_Light_Color | Patio_Light_Bulb | Control,Light |
    And code in a rules file
      """
        items => [*, { <pattern> } => matched, *]
        logger.debug("Matched #{matched.name}")
      """
    When I deploy the rules file
    Then It should log 'Matched <item_name>' within 5 seconds
    Examples: Semantic patterns
      | pattern                                               | item_name         |
      | type: ColorItem, point_type: Semantics::Control       | Patio_Light_Color |
      | type: ColorItem, equipment_type: Semantics::Lightbulb | Patio_Light_Color |
      | type: ColorItem, property_type: Semantics::Light      | Patio_Light_Color |
      | type: ColorItem, semantic_type: Semantics::Control    | Patio_Light_Color |
      | type: ColorItem, location_type: Semantics::Patio      | Patio_Light_Color |


  # TODO: For some reason pattern matching is failing if that group does not exist
  Scenario Outline: Item extension pattern matching
    Given groups:
      | name   | groups   | tags  |
      | gPatio | gOutdoor | Patio |
    Given items:
      | type  | name        | state       |
      | Color | Patio_Light | 0, 100, 100 |
      | Image | image       |             |

    And code in a rules file
      """
        image.update "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABAQMAAAAl21bKAAAAA1BMVEUAAACnej3aAAAAAXRSTlMAQObYZgAAAApJREFUCNdjYAAAAAIAAeIhvDMAAAAASUVORK5CYII="
        Patio_Light.deconstruct_keys(nil).each { |key, value| logger.debug("#{key}=#{value}")}
        items.to_a => [*, { <pattern> } => matched, *]
        logger.debug("Matched #{matched.name}")
      """
    When I deploy the rules file
    Then It should log 'Matched <item_name>' within 5 seconds
    Examples: Semantic patterns
      | pattern                            | item_name   |
      | mime_type: 'image/png'             | image       |
      | name: "Patio_Light"                | Patio_Light |
      | id: "Patio_Light"                  | Patio_Light |
      | hex: '#ff0000'                     | Patio_Light |
      | rgb: {red: 255, green: 0, blue: 0} | Patio_Light |
