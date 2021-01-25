Feature:  Temporary patches

  Background:
    Given Clean OpenHAB with latest Ruby Libraries
    And groups:
      | name         | group |
      | Temperatures |       |
    And items:
      | type   | name            | label                   | state | groups       |
      | Number | Livingroom_Temp | Living Room temperature | 70    | Temperatures |
      | Number | Bedroom_Temp    | Bedroom temperature     | 50    | Temperatures |
      | Number | Den_Temp        | Den temperature         | 30    | Temperatures |


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

