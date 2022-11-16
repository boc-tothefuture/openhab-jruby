Feature:  every
  Rule languages supports cron features

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario: Using cron shortcuts ':second'
    Given a rule
      """
      rule 'Log the rule name every second' do | rule |
        every :second
        run { logger.info "Rule '#{rule.name}' executed" }
      end
      """
    When I deploy the rule
    Then It should log "Rule 'Log the rule name every second' executed" within 5 seconds

  Scenario Outline: Cron support days of the week and time of day
    Given a rule template:
      """
      def five_seconds_from_now_string
        (Time.now + 5).strftime('%H:%M:%S')
      end

      def five_seconds_from_now_localtime
        LocalTime.parse(five_seconds_from_now_string)
      end

      rule 'Simple' do | rule |
        every  <%= ":#{Date.today.strftime('%A').downcase.to_sym}" %>, at: <five_seconds_from_now>
        run { logger.info "Rule #{rule.name} executed" }
      end
      """
    When I deploy the rule
    Then It should log 'Rule Simple executed' within 15 seconds

    Examples:
      | five_seconds_from_now           |
      | five_seconds_from_now_string    |
      | five_seconds_from_now_localtime |

  Scenario: Using durations
    Given a rule
      """
      rule 'Every 5 seconds' do | rule |
        every 5.seconds
        run { logger.info "Rule #{rule.name} executed" }
      end
      """
    When I deploy the rule
    Then It should log 'Rule Every 5 seconds executed' within 10 seconds

  Scenario Outline: Every can use MonthDay
    Given a rule:
      """
      time = (Time.now + 3).strftime('%H:%M:%S')
      today = ZonedDateTime.now

      def monthday(zdt)
        MonthDay.of(zdt.month_value, zdt.day_of_month)
      end

      rule 'Every MonthDay' do
        every <monthday>, at: time
        run { logger.info "Rule Every MonthDay executed" }
      end
      """
    When I deploy the rule
    Then It <should> log 'Rule Every MonthDay executed' within 5 seconds
    Examples:
      | monthday                        | should     |
      | monthday(today)                 | should     |
      | monthday(today).to_s            | should     |
      | monthday(today.plus_days(1))    | should not |
      | monthday(today.minus_days(1))   | should not |
      | monthday(today.plus_months(1))  | should not |
      | monthday(today.minus_months(1)) | should not |

