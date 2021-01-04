Feature:  Openhab Action Support

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  @not_implemented
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

  @not_implemented
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

  Scenario: After can be used to manage timers
    Given items:
      | type   | name       | state |
      | Switch | TestSwitch | OFF   |
    Given a deployed rule:
      """
      rule 'Execute something while a switch is set to ON' do
        changed TestSwitch
        run { logger.info("button changed event")}
        run do
           java_import java.time.ZonedDateTime
          timer = after(1.second) do
            if TestSwitch.on?
              logger.info("button still changed to ON")
              timer.reschedule(ZonedDateTime.now.plus(Java::JavaTime::Duration.ofSeconds(1)))
            end
          end
        end
      end
      """
    When item "TestSwitch" state is changed to "ON"
    Then It should log 'button still changed to ON' within 5 seconds
    And item "TestSwitch" state is changed to "OFF"
    And if I wait 2 seconds
    Then It should not log 'button still changed to ON' within 5 seconds
