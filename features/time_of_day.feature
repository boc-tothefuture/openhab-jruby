Feature:  time_of_day
  Rule languages supports comparing using TimeOfDay

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

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


  Scenario Outline: TimeOfDay object can be compared against other objects
    Given a rule:
      """
      logger.info("Time of day compare result: #{<comparison>}")
      """
    When I deploy the rule
    Then It should log "Time of day compare result: <result>" within 5 seconds
    Examples: Comparison against String
      | comparison                  | result |
      | TimeOfDay.noon < '12:05:00' | true   |
      | TimeOfDay.noon < '11:55:00' | false  |
      | '12:05:00' > TimeOfDay.noon | true   |
      | '12:05:00' < TimeOfDay.noon | false  |
      | '12pm' == TimeOfDay.noon    | true   |
      | TimeOfDay.noon == '12pm'    | true   |
    Examples: Comparison against LocalTime
      | comparison                                       | result |
      | TimeOfDay.noon < LocalTime::NOON.plusMinutes(5)  | true   |
      | TimeOfDay.noon < LocalTime::NOON.minusMinutes(5) | false  |
      | LocalTime::NOON.minusMinutes(5) < TimeOfDay.noon | true   |
      | LocalTime::NOON.minusMinutes(5) > TimeOfDay.noon | false  |
      | TimeOfDay.noon == LocalTime::NOON                | true   |
      | LocalTime::NOON == TimeOfDay.noon                | true   |

  Scenario Outline: TimeOfDay object between? method
    Given a rule:
      """
      logger.info("TimeOfDay is in the range: #{TimeOfDay.noon.between? <from>..<to>}")
      """
    When I deploy the rule
    Then It should log "TimeOfDay is in the range: <result>" within 2 seconds
    Examples:
      | from                            | to                             | result |
      | '11:55:00'                      | '12:05:00'                     | true   |
      | '12:05:00'                      | '12:10:00'                     | false  |
      | LocalTime::NOON.minusMinutes(5) | LocalTime::NOON.plusMinutes(5) | true   |
      | LocalTime::NOON.plusMinutes(3)  | LocalTime::NOON.plusMinutes(5) | false  |
