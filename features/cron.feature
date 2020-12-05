Feature:  Rule languages supports cron features

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario: Using cron shortcuts ':minute'
    Given a rule
      """
            rule 'Simple' do
              every :minute
              run { logger.info "Rule #{name} executed" }
            end
      """
    When I deploy the rule
    Then It should log 'Rule Simple executed' within 60 seconds

  @wip
  Scenario Outline: Cron support days of the week and time of day
    Given a rule template:
      """
            def five_seconds_from_now_string
              (Time.now + 5).strftime('%H:%M:%S')
            end

            def five_seconds_from_now_tod
              TimeOfDay.parse(five_seconds_from_now_string)
            end

            rule 'Simple' do
              every  <%= ":#{Date.today.strftime('%A').downcase.to_sym}" %>, at: <five_seconds_from_now>
              run { logger.info "Rule #{name} executed" }
            end
      """
    When I deploy the rule
    Then It should log 'Rule Simple executed' within 15 seconds

    Examples:
      | five_seconds_from_now        |
      | five_seconds_from_now_string |
      | five_seconds_from_now_tod    |


