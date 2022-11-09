Feature:  time
  Rule languages supports extensions to time classes

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario Outline: ZonedDateTime supports comparison operators
    Given a rule:
      """
      ruby_now = Time.now
      zdt_now = ruby_now.to_java(ZonedDateTime)
      logger.info("Comparison result: #{<comparison>}")
      logger.info("#{zdt_now} / #{ruby_now} #{ruby_now.nsec}")
      """
    When I deploy the rule
    Then It should log "Comparison result: <result>" within 5 seconds
    Examples:
      | comparison                               | result |
      | zdt_now < zdt_now.plus_minutes(1)        | true   |
      | zdt_now < Time.now + 100                 | true   |
      | Time.now < Time.now.to_zdt.plus_hours(1) | true   |
      | Time.now + 10 < zdt_now                  | false  |
      | zdt_now.before?(Time.now + 10)           | true   |
      | zdt_now.before?(Time.now - 10)           | false  |
      | zdt_now == zdt_now                       | true   |
      | zdt_now == ruby_now                      | true   |
      | ruby_now == zdt_now                      | true   |
      | ruby_now != zdt_now                      | false  |

  Scenario Outline: LocalTime supports comparison operators
    Given a rule:
      """
      ruby_now = TimeOfDay.now
      lt_now = ruby_now.local_time
      logger.info("Comparison result: #{<comparison>}")
      logger.info("#{lt_now} / #{ruby_now}")
      """
    When I deploy the rule
    Then It should log "Comparison result: <result>" within 5 seconds
    Examples:
      | comparison                                    | result |
      | LocalTime.now < LocalTime.now.plus_minutes(1) | true   |
      | LocalTime.now - 1.minute < TimeOfDay.now      | true   |
      | TimeOfDay.now < LocalTime.now.plus_hours(1)   | true   |
      | TimeOfDay.now  < LocalTime.now - 1.second     | false  |
      | lt_now == lt_now                              | true   |
      | lt_now == ruby_now                            | true   |
      | ruby_now == lt_now                            | true   |
      | ruby_now != lt_now                            | false  |
