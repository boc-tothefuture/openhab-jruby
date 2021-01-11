Feature:  Rule languages supports storing and restoring states

    Background:
        Given Clean OpenHAB with latest Ruby Libraries
        And items:
            | type   | name    | label             | state |
            | Switch | Switch1 | Switch Number One | OFF   |
            | Switch | Switch2 | Switch Number Two | OFF   |


    Scenario: States can be stored and restored using store_states
        Given code in a rules file:
            """
            states = store_states Switch1, Switch2
            Switch1 << ON
            after(5.seconds) { states.restore }
            """
        When I deploy the rule
        Then "Switch1" should be in state "ON" within 2 seconds
        But If I wait 5 seconds
        Then "Switch1" should be in state "OFF" within 2 seconds

    Scenario: States can be stored and restored using store_states block
        Given code in a rules file:
            """
            store_states Switch1, Switch2 do
              Switch1 << ON
              sleep 5
            end
            """
        When I deploy the rule
        Then "Switch1" should be in state "ON" within 2 seconds
        But If I wait 5 seconds
        Then "Switch1" should be in state "OFF" within 2 seconds