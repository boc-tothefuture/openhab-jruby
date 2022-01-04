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


  Scenario Outline: Between ranges work inside of rule execution blocks
    Given a rule template:
      """
      rule 'Testing Between Range' do
        on_start
        run do
          range = between <between>
          logger.info("Within time range") if range.cover? <compare>
        end
      end
      """
    When I deploy the rule
    Then It <should> log "Within time range" within 5 seconds
    Examples: Checks Time, TimeOfDay and Strings
      | between                                                                                           | compare  | should     |
      | '<%=(Time.now - (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'  | Time.now | should     |
      | '<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (10*60)).strftime('%H:%M:%S')%>' | Time.now | should not |


  Scenario Outline: Between supports Day of Month
    Given a rule template:
      """
      require 'date'
      range = between <between>
      in_range = range.include?(<compare>)
      logger.info("in range: #{in_range}")
      """
    When I deploy the rule
    Then It should log "in range: <result>" within 5 seconds
    Examples: Checks in range, before range and after range
      | between                                                                                    | compare    | result |
      | '<%=Date.today.prev_day.strftime('%m-%d')%>'..'<%=Date.today.next_day.strftime('%m-%d')%>' | Date.today | true   |
      | '<%=(Date.today + 10 ).strftime('%m-%d')%>'..'<%=(Date.today + 20).strftime('%m-%d')%>'    | Date.today | false  |
      | '<%=(Date.today - 20 ).strftime('%m-%d')%>'..'<%=(Date.today - 10).strftime('%m-%d')%>'    | Date.today | false  |


  Scenario Outline: Day of Month between ranges support multiple compare types
    Given a rule template:
      """
      require 'date'
      range = between <between>
      in_range = range.include?(<compare>)
      logger.info("in range: #{in_range}")
      """
    When I deploy the rule
    Then It should log "in range: <result>" within 5 seconds
    Examples: Checks Date, Time, and DateTime
      | between                                                                                    | compare      | result |
      | '<%=Date.today.prev_day.strftime('%m-%d')%>'..'<%=Date.today.next_day.strftime('%m-%d')%>' | Date.today   | true   |
      | '<%=Date.today.prev_day.strftime('%m-%d')%>'..'<%=Date.today.next_day.strftime('%m-%d')%>' | Time.now     | true   |
      | '<%=Date.today.prev_day.strftime('%m-%d')%>'..'<%=Date.today.next_day.strftime('%m-%d')%>' | DateTime.now | true   |
      | '<%=Date.today.prev_day.strftime('%m-%d')%>'..'<%=Date.today.next_day.strftime('%m-%d')%>' | MonthDay.now | true   |

  Scenario Outline: Between supports strings and MonthDay objects for ranges
    Given a rule template:
      """
      require 'date'
      require 'java'
      java_import java.time.LocalDate
      today = LocalDate.now
      date_yesterday = today.minus_days(1)
      date_tomorrow = today.plus_days(1)
      yesterday = MonthDay.of(date_yesterday.month_value, date_yesterday.day_of_month)
      tomorrow = MonthDay.of(date_tomorrow.month_value, date_tomorrow.day_of_month)
      range = between <between>
      in_range = range.include?(<compare>)
      logger.info("in range: #{in_range}")
      """
    When I deploy the rule
    Then It should log "in range: <result>" within 5 seconds
    Examples: Checks in range, before range and after range
      | between                                                                                    | compare    | result |
      | '<%=Date.today.prev_day.strftime('%m-%d')%>'..'<%=Date.today.next_day.strftime('%m-%d')%>' | Date.today | true   |
      | yesterday..tomorrow                                                                        | Date.today | true   |
      | yesterday..'<%=Date.today.next_day.strftime('%m-%d')%>'                                    | Date.today | true   |
      | '<%=Date.today.prev_day.strftime('%m-%d')%>'..tomorrow                                     | Date.today | true   |

  Scenario Outline: Between supports range rollover
    Given a rule template:
      """
      result = <type>.parse('<value>').between?(<range>)
      logger.info("between? #{result}")
      """
    When I deploy the rule
    Then It should log "between? <result>" within 5 seconds
    Examples: Checks range
      | type     | value | range            | result |
      # | TimeOfDay | 23:00 | '20:00'..'02:00' | true   |
      # | TimeOfDay | 19:00 | '20:00'..'02:00' | false  |
      # | TimeOfDay | 1:00  | '20:00'..'02:00' | true   |
      # | TimeOfDay | 3:00  | '20:00'..'02:00' | false  |
      | MonthDay | 12-25 | '12-01'..'01-05' | true   |
      | MonthDay | 11-25 | '12-01'..'01-05' | false  |
      | MonthDay | 01-01 | '12-01'..'01-05' | true   |
      | MonthDay | 01-20 | '12-01'..'01-05' | false  |

