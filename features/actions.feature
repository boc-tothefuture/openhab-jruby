Feature:  actions
  Provides support for OpenHAB actions

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario: send notification to a user
    Given a rule
      """
      logger.info("Action <action> is defined: #{defined? <action>}")
      """
    When I deploy the rule
    Then It should log 'Action <action> is defined: constant' within 5 seconds
    Examples: Actions always available
      | action |
      | Exec   |
      | Ping   |
      | HTTP   |
      | Audio  |
      | Voice  |

  Scenario: Exec action is supported
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

  Scenario: Access generic actions on thing
    And feature 'openhab-binding-mail' installed
    And things:
      | id   | thing_uid | label     | config                                                | status |
      | test | mail:smtp | Test SMTP | {"hostname":"localhost", "sender":"mail@example.com"} | enable |
    And code in a rules file
      """
        logger.info('Action method sendMail exists') if things['mail:smtp:test'].respond_to? :sendMail
      """
    When I deploy the rule
    Then It should log "Action method sendMail exists" within 5 seconds

  Scenario: Access generic actions using actions method
    And feature 'openhab-binding-mail' installed
    And things:
      | id   | thing_uid | label     | config                                                | status |
      | test | mail:smtp | Test SMTP | {"hostname":"localhost", "sender":"mail@example.com"} | enable |
    And code in a rules file
      """
        logger.info('Action method sendMail exists') if actions('mail', 'mail:smtp:test').respond_to? :sendMail
      """
    When I deploy the rule
    Then It should log "Action method sendMail exists" within 5 seconds

  Scenario: Use say action wrapper from a rule
    Given items:
      | type   | name        | label  | state  |
      | Switch | LightSwitch | Switch | OFF    |
    And a rule
      """
      rule 'Use say' do
        changed LightSwitch
        run do
          say("something")
          logger.info("Switch changed")
        end
      end
      """
    When I deploy the rule
    And item "LightSwitch" state is changed to "ON"
    Then It should log "Switch changed" within 5 seconds
