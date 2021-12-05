Feature: location_item
  Location Items are supported

  Background:
    Given Clean OpenHAB with latest Ruby Libraries
    And items:
      | type     | name     |
      | Location | Location |

  Scenario Outline:  Location items can be updated
    Given code in a rules file:
      """
      Location << <command>
      """
    When I deploy the rules file
    Then "Location" should be in state "<final>" within 5 seconds
    Examples:
      | command                                       | final    |
      | '30,20'                                       | 30,20    |
      | '30,20,80'                                    | 30,20,80 |
      | PointType.new('40,20')                        | 40,20    |
      | {lat: 30, long: 30}                           | 30,30    |
      | {latitude: 30, longitude: 30}                 | 30,30    |
      | {lat: 30, long: 30, alt: 80}                  | 30,30,80 |
      | {latitude: 30, longitude: 30, altitude: 80}   | 30,30,80 |


  Scenario: LocationItem alias '-' to distance_from
    Given items:
      | type     | name      | state |
      | Location | Location1 | 30,20 |
      | Location | Location2 | 40,20 |
    And code in a rules file:
      """
      logger.info "Distance from Location 1 to Location 2: #{Location1 - Location2}"
      """
    When I deploy the rules file
    Then It should log 'Distance from Location 1 to Location 2: 1113194' within 5 seconds

  Scenario Outline: distance_from accepts supported types
    Given items:
      | type     | name      | state |
      | Location | Location1 | 30,20 |
      | Location | Location2 | 40,20 |
    And code in a rules file:
      """
      logger.info "Distance from Location 1 to Location 2: #{<lhs>.distance_from(<rhs>)}"
      """
    When I deploy the rules file
    Then It should log 'Distance from Location 1 to Location 2: 1113194' within 5 seconds
    Examples:
      | lhs                    | rhs                              |
      | Location1              | Location2                        |
      | Location1              | Location2.state                  |
      | Location1              | '40,20'                          |
      | Location1              | {lat: 40, long: 20}              |
      | Location1              | {latitude: 40, longitude: 20}    |
      | Location1              | PointType.new('40,20')           |
      | Location2              | Location1                        |
      | Location2.state        | Location1                        |
      | PointType.new('40,20') | Location1                        |
