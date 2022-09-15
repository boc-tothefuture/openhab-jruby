Feature:  time
  Rule languages supports extensions to time classes

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario Outline: ZonedDateTime supports arithmetic operators against Duration
    Given a rule:
      """
      now = ZonedDateTime.now
      logger.info("<a>.equals(<b>): #{<a>.equals(<b>)}")
      """
    When I deploy the rule
    Then It should log "<a>.equals(<b>): <result>" within 5 seconds
    Examples:
      | a                   | b               | result |
      | now.plus(1.minutes) | now + 1.minutes | true   |
      | now.minus_hours(2)  | now - 2.hours   | true   |

  Scenario Outline: LocalTime supports arithmetic operators against Duration
    Given a rule:
      """
      now = LocalTime.now
      logger.info("<a>.equals(<b>): #{<a>.equals(<b>)}")
      """
    When I deploy the rule
    Then It should log "<a>.equals(<b>): <result>" within 5 seconds
    Examples:
      | a                   | b               | result |
      | now.plus(1.minutes) | now + 1.minutes | true   |
      | now.minus_hours(2)  | now - 2.hours   | true   |

  Scenario Outline: Ruby Time supports arithmetic operators against Duration
    Given a rule:
      """
      now = Time.now
      logger.info("<a> == <b>: #{<a> == <b>}")
      """
    When I deploy the rule
    Then It should log "<a> == <b>: <result>" within 5 seconds
    Examples:
      | a          | b              | result |
      | now + 60   | now + 1.minute | true   |
      | now - 3600 | now - 1.hour   | true   |

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
