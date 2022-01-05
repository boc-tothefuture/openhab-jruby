Feature: between
  Rule languages supports between

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario Outline: Between ranges can be checked with cover? with different representations of time
    Given a rule template:
      """
      range = between <between>
      log = range.cover?(<compare>) ?  "Within" : "Outside"
      logger.info("#{log} time range") 
      """
    When I deploy the rule
    Then It should log "<log> time range" within 5 seconds
    Examples: Checks Time, TimeOfDay and Strings
      | between                                                                                           | compare                                | log        |
      | '<%=(Time.now - (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'  | Time.now                               | Within     |
      | '<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (10*60)).strftime('%H:%M:%S')%>' | Time.now                               | Outside    |
      | '<%=(Time.now - (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'  | TimeOfDay.now                          | Within     |
      | '<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (10*60)).strftime('%H:%M:%S')%>' | TimeOfDay.now                          | Outside    |
      | '<%=(Time.now - (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'  | '<%=(Time.now).strftime('%H:%M:%S')%>' | Within     |
      | '<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (10*60)).strftime('%H:%M:%S')%>' | '<%=(Time.now).strftime('%H:%M:%S')%>' | Outside    |


  Scenario Outline: Between ranges can be checked with include? with different representations of time
    Given a rule template:
      """
      range = between <between>
      log = range.include?(<compare>) ?  "Within" : "Outside"
      logger.info("#{log} time range") 
      """
    When I deploy the rule
    Then It should log "<log> time range" within 5 seconds
    Examples: Checks Time, TimeOfDay and Strings
      | between                                                                                           | compare                                | log        |
      | '<%=(Time.now - (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'  | Time.now                               | Within     |
      | '<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (10*60)).strftime('%H:%M:%S')%>' | Time.now                               | Outside    |
      | '<%=(Time.now - (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'  | TimeOfDay.now                          | Within     |
      | '<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (10*60)).strftime('%H:%M:%S')%>' | TimeOfDay.now                          | Outside    |
      | '<%=(Time.now - (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'  | '<%=(Time.now).strftime('%H:%M:%S')%>' | Within     |
      | '<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (10*60)).strftime('%H:%M:%S')%>' | '<%=(Time.now).strftime('%H:%M:%S')%>' | Outside    |


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
    Then It should log "<log> time range" within 5 seconds
    Examples: Checks Time, TimeOfDay and Strings
      | between                                                                                           | compare                                | log        |
      | '<%=(Time.now - (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'  | Time.now                               | Within     |
      | '<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (10*60)).strftime('%H:%M:%S')%>' | Time.now                               | Not in     |
      | '<%=(Time.now - (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'  | TimeOfDay.now                          | Within     |
      | '<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (10*60)).strftime('%H:%M:%S')%>' | TimeOfDay.now                          | Not in     |
      | '<%=(Time.now - (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'  | '<%=(Time.now).strftime('%H:%M:%S')%>' | Within     |
      | '<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (10*60)).strftime('%H:%M:%S')%>' | '<%=(Time.now).strftime('%H:%M:%S')%>' | Not in     |


  Scenario Outline: Between ranges work inside of rule execution blocks
    Given a rule template:
      """
      rule 'Testing Between Range' do
        on_start
        run do
          range = between <between>
          if range.cover? <compare>
            logger.info("Within time range") 
          else 
            logger.info("Outside time range") 
          end
        end
      end
      """
    When I deploy the rule
    Then It should log "<log> time range" within 5 seconds
    Examples: Checks Time, TimeOfDay and Strings
      | between                                                                                           | compare  | log        |
      | '<%=(Time.now - (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'  | Time.now | Within     |
      | '<%=(Time.now + (5*60)).strftime('%H:%M:%S')%>'..'<%=(Time.now + (10*60)).strftime('%H:%M:%S')%>' | Time.now | Outside    |


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
      | between                                                                                    | compare    | operation | result |
      | '<%=Date.today.prev_day.strftime('%m-%d')%>'..'<%=Date.today.next_day.strftime('%m-%d')%>' | Date.today | cover?    | true   |
      | '<%=(Date.today + 10 ).strftime('%m-%d')%>'..'<%=(Date.today + 20).strftime('%m-%d')%>'    | Date.today | cover?    | false  |
      | '<%=(Date.today - 20 ).strftime('%m-%d')%>'..'<%=(Date.today - 10).strftime('%m-%d')%>'    | Date.today | cover?    | false  |
      | '<%=Date.today.prev_day.strftime('%m-%d')%>'..'<%=Date.today.next_day.strftime('%m-%d')%>' | Date.today | include?  | true   |
      | '<%=(Date.today + 10 ).strftime('%m-%d')%>'..'<%=(Date.today + 20).strftime('%m-%d')%>'    | Date.today | include?  | false  |
      | '<%=(Date.today - 20 ).strftime('%m-%d')%>'..'<%=(Date.today - 10).strftime('%m-%d')%>'    | Date.today | include?  | false  |

  Scenario Outline: Between supports checking between months
    Given a rule template:
      """
      result = between(<range>).include? <type>.parse('<value>')
      logger.info("between? #{result}")
      """
    When I deploy the rule
    Then It should log "between? <result>" within 5 seconds
    Examples: Checks range
      | type     | value | range            | result |
      | MonthDay | 02-03 | '01-25'..'02-05' | true   |
      | MonthDay | 11-25 | '01-25'..'02-05' | false  |


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
      | between                                                                                    | compare      | operation | result | 
      | '<%=Date.today.prev_day.strftime('%m-%d')%>'..'<%=Date.today.next_day.strftime('%m-%d')%>' | Date.today   | cover?    | true   |
      | '<%=Date.today.prev_day.strftime('%m-%d')%>'..'<%=Date.today.next_day.strftime('%m-%d')%>' | Time.now     | cover?    | true   |
      | '<%=Date.today.prev_day.strftime('%m-%d')%>'..'<%=Date.today.next_day.strftime('%m-%d')%>' | DateTime.now | cover?    | true   |
      | '<%=Date.today.prev_day.strftime('%m-%d')%>'..'<%=Date.today.next_day.strftime('%m-%d')%>' | MonthDay.now | cover?    | true   |
      | '<%=Date.today.prev_day.strftime('%m-%d')%>'..'<%=Date.today.next_day.strftime('%m-%d')%>' | Date.today   | include?  | true   |
      | '<%=Date.today.prev_day.strftime('%m-%d')%>'..'<%=Date.today.next_day.strftime('%m-%d')%>' | Time.now     | include?  | true   |
      | '<%=Date.today.prev_day.strftime('%m-%d')%>'..'<%=Date.today.next_day.strftime('%m-%d')%>' | DateTime.now | include?  | true   |
      | '<%=Date.today.prev_day.strftime('%m-%d')%>'..'<%=Date.today.next_day.strftime('%m-%d')%>' | MonthDay.now | include?  | true   |



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

