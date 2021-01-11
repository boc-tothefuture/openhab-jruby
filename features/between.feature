Feature:  Rule languages supports between

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario Outline: Between ranges can be compared to different representations of time
    Given a rule template:
      """
      range = between <between>
      logger.info("Within time range") if range.cover? <compare>
      """
    When I deploy the rule
    Then It <should> log "Within time range" within 5 seconds
    Examples:
      | between                                                                                           | compare                                                           | should     |
      | '<%=(Time.now - (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'  | Time.now                                                          | should     |
      | '<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (10*60)).strftime('%H:%M:%S')%>' | Time.now                                                          | should not |
      | '<%=(Time.now - (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'  | TimeOfDay.new(h: Time.now.hour, m: Time.now.min, s: Time.now.sec) | should     |
      | '<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (10*60)).strftime('%H:%M:%S')%>' | TimeOfDay.new(h: Time.now.hour, m: Time.now.min, s: Time.now.sec) | should not |
      | '<%=(Time.now - (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'  | '<%=(Time.now).strftime('%H:%M:%S')%>'                            | should     |
      | '<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (10*60)).strftime('%H:%M:%S')%>' | '<%=(Time.now).strftime('%H:%M:%S')%>'                            | should not |


