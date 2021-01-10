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
          user = 'user@example.com'
          notify('Test Alert', email: user)
          logger.info("Notified #{user}")
         end
      end
      """
    When I deploy the rule
    Then It should log 'Notified user@example.com' within 5 seconds

  @not_implemented
  Scenario: send to all users
    Given a rule
      """
      rule 'Notify all user' do
        on_start
        run do
          notify('Test Alert')
          logger.info("Notified All Users")
         end
      end
      """
    When I deploy the rule
    Then It should log 'Notified All users' within 5 seconds

  Scenario: Execute a command line
    Given a rule
      """
      java_import java.time.Duration
      rule 'Execute command line' do
        on_start
        run do
          output = Exec.executeCommandLine(Duration.ofSeconds(2), '/bin/echo', 'Hello, World!').chomp
          logger.info("executeCommandLine output: '#{output}'")
        end
      end
      """
    When I deploy the rule
    Then It should log "executeCommandLine output: 'Hello, World!'" within 5 seconds