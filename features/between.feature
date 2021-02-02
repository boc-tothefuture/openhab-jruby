Feature: between
  Rule languages supports between

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario Outline: Between ranges can be checked with cover? with different representations of time
    Given a rule template:
      """
      range = between <between>
      logger.info("Within time range") if range.cover? <compare>
      """
    When I deploy the rule
    Then It <should> log "Within time range" within 5 seconds
    Examples: Checks Time, TimeOfDay and Strings
      | between                                                                                           | compare                                | should     |
      | '<%=(Time.now - (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'  | Time.now                               | should     |
      | '<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (10*60)).strftime('%H:%M:%S')%>' | Time.now                               | should not |
      | '<%=(Time.now - (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'  | TimeOfDay.now                          | should     |
      | '<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (10*60)).strftime('%H:%M:%S')%>' | TimeOfDay.now                          | should not |
      | '<%=(Time.now - (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'  | '<%=(Time.now).strftime('%H:%M:%S')%>' | should     |
      | '<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (10*60)).strftime('%H:%M:%S')%>' | '<%=(Time.now).strftime('%H:%M:%S')%>' | should not |


  Scenario Outline: Between ranges can be checked with include? with different representations of time
    Given a rule template:
      """
      range = between <between>
      logger.info("Within time range") if range.include? <compare>
      """
    When I deploy the rule
    Then It <should> log "Within time range" within 5 seconds
    Examples: Checks Time, TimeOfDay and Strings
      | between                                                                                           | compare                                | should     |
      | '<%=(Time.now - (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'  | Time.now                               | should     |
      | '<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (10*60)).strftime('%H:%M:%S')%>' | Time.now                               | should not |
      | '<%=(Time.now - (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'  | TimeOfDay.now                          | should     |
      | '<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (10*60)).strftime('%H:%M:%S')%>' | TimeOfDay.now                          | should not |
      | '<%=(Time.now - (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'  | '<%=(Time.now).strftime('%H:%M:%S')%>' | should     |
      | '<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (10*60)).strftime('%H:%M:%S')%>' | '<%=(Time.now).strftime('%H:%M:%S')%>' | should not |


  Scenario Outline: Between ranges can be used in case statements
    Given a rule template:
      """
      case <compare>
      when between(<between>)
        logger.info("Within time range")
      else
        logger.info("Not in time range")
      end
      """
    When I deploy the rule
    Then It <should> log "Within time range" within 5 seconds
    Examples: Checks Time, TimeOfDay and Strings
      | between                                                                                           | compare                                | should     |
      | '<%=(Time.now - (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'  | Time.now                               | should     |
      | '<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (10*60)).strftime('%H:%M:%S')%>' | Time.now                               | should not |
      | '<%=(Time.now - (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'  | TimeOfDay.now                          | should     |
      | '<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (10*60)).strftime('%H:%M:%S')%>' | TimeOfDay.now                          | should not |
      | '<%=(Time.now - (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'  | '<%=(Time.now).strftime('%H:%M:%S')%>' | should     |
      | '<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (10*60)).strftime('%H:%M:%S')%>' | '<%=(Time.now).strftime('%H:%M:%S')%>' | should not |

