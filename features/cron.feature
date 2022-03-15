Feature:  cron
  Rule languages supports cron features

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario: Can use cron syntax to create a rule
    Given a rule
      """
      def five_seconds_from_now
        cron = (Time.now + 5).strftime('%S %M %H ? * ?').tap { |cron| logger.info(cron)}
      end

      rule 'Using Cron Syntax' do
        cron five_seconds_from_now
        run { logger.info "Cron rule executed" }
      end
      """
    When I deploy the rule
    Then It should log 'Cron rule executed' within 15 seconds

  Scenario: Cron can use specifiers
    Given a rule
      """
      schedule = Time.now + 5

      rule 'Using Cron Syntax' do
        cron second: schedule.sec, minute: schedule.min
        run { logger.info "Cron rule executed" }
      end
      """
    When I deploy the rule
    Then It should not log 'Cron rule executed' within 3 seconds
    And It should log 'Cron rule executed' within 10 seconds