Feature: month_day
  Rule languages supports MonthDay

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario: MonthDay supports keyword arguments
    Given a rule:
      """
      md = MonthDay.new(m: 12, d: 25)
      logger.info("md: #{md}")
      """
    When I deploy the rule
    Then It should log "md: 12-25" within 5 seconds

  Scenario Outline: MonthDay supports range
    Given a rule template:
      """
      result = <type>.parse('<value>').between?(<range>)
      logger.info("between? #{result}")
      """
    When I deploy the rule
    Then It should log "between? <result>" within 5 seconds
    Examples: Normal Range
      | type     | value | range             | result |
      | MonthDay | 01-20 | '12-01'..'12-05'  | false  |
      | MonthDay | 12-01 | '12-01'..'12-05'  | true   |
      | MonthDay | 12-03 | '12-01'..'12-05'  | true   |
      | MonthDay | 12-05 | '12-01'..'12-05'  | true   |
      | MonthDay | 12-05 | '12-01'...'12-05' | false  |
      | MonthDay | 12-06 | '12-01'..'12-05'  | false  |
    Examples: Same Day Range
      | type     | value | range             | result |
      | MonthDay | 12-01 | '12-02'..'12-02'  | false  |
      | MonthDay | 12-02 | '12-02'..'12-02'  | true   |
      | MonthDay | 12-03 | '12-02'..'12-02'  | false  |

  Scenario Outline: MonthDay range supports Feb 29th
    Given a rule template:
      """
      result = <type>.parse('<value>').between?(<range>)
      logger.info("between? #{result}")
      """
    When I deploy the rule
    Then It should log "between? <result>" within 5 seconds
    Examples: Leap year check
      | type     | value | range             | result |
      | MonthDay | 02-29 | '02-01'..'03-01'  | true   |
      | MonthDay | 02-29 | '02-01'...'03-01' | true   |

  Scenario Outline: MonthDay range can span end of year
    Given a rule template:
      """
      result = <type>.parse('<value>').between?(<range>)
      logger.info("between? #{result}")
      """
    When I deploy the rule
    Then It should log "between? <result>" within 5 seconds
    Examples: Ranges crossing over end of the year
      | type     | value | range             | result |
      | MonthDay | 11-25 | '12-01'..'01-05'  | false  |
      | MonthDay | 12-01 | '12-01'..'01-05'  | true   |
      | MonthDay | 12-25 | '12-01'..'01-05'  | true   |
      | MonthDay | 01-01 | '12-01'..'01-05'  | true   |
      | MonthDay | 01-05 | '12-01'..'01-05'  | true   |
      | MonthDay | 01-05 | '12-01'...'01-05' | false  |
      | MonthDay | 01-20 | '12-01'..'01-05'  | false  |
