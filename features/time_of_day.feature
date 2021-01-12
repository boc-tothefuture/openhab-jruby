Feature:  Rule languages supports comparing using TimeOfDay

    Background:
        Given Clean OpenHAB with latest Ruby Libraries

    Scenario Outline: Between guards accept strings to guard rule execution based on time of day
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


    Scenario Outline: Parse strings into a TimeOfDay object
        Given a rule template:
            """
            begin
              logger.info("TimeOfDay is #{TimeOfDay.parse <template_time>}")
            rescue ArgumentError => e
              logger.error("Error parsing time #{e}")
            end
            """
        When I deploy the rule
        Then It should log "<log_line>" within 5 seconds
        Examples:
            | template_time | log_line              |
            | '1'           | TimeOfDay is 01:00    |
            | '02'          | TimeOfDay is 02:00    |
            | '1pm'         | TimeOfDay is 13:00    |
            | '12:30'       | TimeOfDay is 12:30    |
            | '12 am'       | TimeOfDay is 00:00    |
            | '7:00 AM'     | TimeOfDay is 07:00    |
            | '7:00 pm'     | TimeOfDay is 19:00    |
            | '7:30:20am'   | TimeOfDay is 07:30:20 |
            | '12  am'      | Error parsing time    |
            | '17:00pm'     | Error parsing time    |
            | '17:00am'     | Error parsing time    |
