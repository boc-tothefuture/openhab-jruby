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