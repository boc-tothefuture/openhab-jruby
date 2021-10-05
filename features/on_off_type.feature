Feature:  on_off_type
    Rule languages supports extensions to OnOffType

    Background:
        Given Clean OpenHAB with latest Ruby Libraries

    Scenario Outline: OnOffType can be used in case statements
        Given items:
            | type   | name    | state   |
            | Switch | Switch1 | <state> |
        And code in a rules file
            """
            case Switch1
            when ON then logger.info('Switch1 is on')
            when OFF then logger.info('Switch1 is off')
            else logger.info('Switch1 is unknown')
            end
            """
        When I deploy the rules file
        Then It should log "Switch1 is <result>" within 5 seconds
        Examples:
            | state | result |
            | ON    | on     |
            | OFF   | off    |


