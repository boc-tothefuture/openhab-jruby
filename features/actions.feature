Feature:  Openhab Action Support

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario: send notification to a user
    Given a rule
      """
      rule 'Notify a user' do
        on_start
        run do
          user = 'user@openhab.com'
          notify(user: user, msg: 'Test Alert')
          logger.info("Notified #{user}")
         end
      end
      """
    When I deploy the rule
    Then It should log 'Notified user@openhab.com' within 5 seconds

  Scenario: send to all users
    Given a rule
      """
      rule 'Notify a user' do
        on_start
        run do
          notify_all('Test Alert')
          logger.info("Notified All Users")
         end
      end
      """
    When I deploy the rule
    Then It should log 'Notified All users' within 5 seconds

