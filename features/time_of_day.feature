Feature:  Rule languages supports comparing using TimeOfDay

    Background:
        Given Clean OpenHAB with latest Ruby Libraries

    Scenario Outline: Parse strings into a TimeOfDay object
        Given a rule template:
            """
            parsed = TimeOfDay.parse <template_time>
            tod = TimeOfDay.new(h: <h>, m: <m>, s: <s>)
            if parsed == tod
                logger.info("TimeOfDay parser is correct")
            end
            """
        When I deploy the rule
        Then It <should> log "TimeOfDay parser is correct" within 2 seconds
        Examples:
            | template_time | h  | m  | s  | should     |
            | '1'           | 1  | 0  | 0  | should     |
            | '02'          | 2  | 0  | 0  | should     |
            | '1pm'         | 13 | 0  | 0  | should     |
            | '12:30'       | 12 | 30 | 0  | should     |
            | '12 am'       | 0  | 0  | 0  | should     |
            | '7:00 AM'     | 7  | 0  | 0  | should     |
            | '7:00 pm'     | 19 | 0  | 0  | should     |
            | '7:30:20am'   | 7  | 30 | 20 | should     |
            | '12  am'      | 0  | 0  | 0  | should not |
            | '17:00pm'     | 17 | 0  | 0  | should not |
            | '17:00am'     | 17 | 0  | 0  | should not |


    Scenario Outline: TimeOfDay object can be compared against a string
        Given a rule template:
            """
        if TimeOfDay.now < <template_time>
          logger.info("Time of day compare succeded")
        end
            """
        When I deploy the rule
        Then It <should> log "Time of day compare succeded" within 5 seconds
        Examples:
            | template_time                                   | should     |
            | '<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>' | should     |
            | '<%=(Time.now - (5*60)).strftime('%H:%M:%S')%>' | should not |


    Scenario Outline: TimeOfDay object between? method 
        Given a rule template:
            """
            if TimeOfDay.now.between? <from>..<to>
                logger.info("TimeOfDay is in the range")
            end
            """
        When I deploy the rule
        Then It <should> log "TimeOfDay is in the range" within 2 seconds
        Examples:
            | from                                         | to                                           | should     |
            | '<%=(Time.now - (5*60)).strftime('%H:%M')%>' | '<%=(Time.now + (5*60)).strftime('%H:%M')%>' | should     |
            | '<%=(Time.now + (5*60)).strftime('%H:%M')%>' | '<%=(Time.now + (7*60)).strftime('%H:%M')%>' | should not |
