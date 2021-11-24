Feature:  logging
  Provides a bridge to OpenHAB Logging

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario Outline: Logging supports trace, debug, warn, info error
    Given code in a rules file
      """
      # Log at a level
      logger.send('<level>'.downcase, 'Test logging at <level>')
      """
    When I deploy the rules file named "log_test.rb"
    Then It should log 'Test logging at <level>' within 5 seconds
    # Waiting on merge for regex test PR
    # Then It should log /\[<level>\].*Test logging at <level>/ within 5 seconds
    Examples:
      | level |
      | TRACE |
      | DEBUG |
      | WARN  |
      | INFO  |
      | ERROR |

  Scenario: Logging accepts block
    Given code in a rules file
      """
      # Log at a level
      logger.error { "Error Message in Block" }
      """
    When I deploy the rules file
    Then It should log 'Error Message in Block' within 5 seconds

  Scenario: Logging outputs file as part of log path
    Given code in a rules file
      """
      # Log at a level
      logger.info("Test logging at for #{__FILE__}")

      rule 'log rule' do
        on_start
        run { logger.info('Log Test') }
      end

      """
    When I deploy the rules file named "log_test.rb"
    Then It should log 'jsr223.jruby.log_test' within 5 seconds

  Scenario Outline: Logging should include rule name inside a rule
    Given items:
      | type   | name    |
      | Switch | Switch1 |
    And a rule:
      """
      rule 'rule 1' do
        <trigger1>
        run { logger.info('1 <trigger1>') }
      end
      rule 'rule 2' do
        <trigger1>
        run { logger.info('2 <trigger1>') }
      end
      rule 'rule 3' do
        <trigger2>
        run { logger.info('3 <trigger2>') }
      end
      rule 'rule 4' do
        <trigger2>
        run { logger.info('4 <trigger2>') }
      end
      """
    When I deploy the rule
    And item "Switch1" state is changed to "ON"
    Then It should log "[jsr223.jruby.rule_1                 ] - 1 <trigger1>" within 5 seconds
    And  It should log "[jsr223.jruby.rule_2                 ] - 2 <trigger1>" within 5 seconds
    And  It should log "[jsr223.jruby.rule_3                 ] - 3 <trigger2>" within 5 seconds
    And  It should log "[jsr223.jruby.rule_4                 ] - 4 <trigger2>" within 5 seconds
    Examples:
      | trigger1                 | trigger2                 |
      | on_start                 | received_command Switch1 |
      | received_command Switch1 | on_start                 |

  Scenario Outline: Logging should include rule name inside a timer
    Given items:
      | type   | name    |
      | Switch | Switch1 |
    And a rule:
      """
      rule 'on start' do
        on_start
        run { after(1.second) { logger.info('inside on_start timer') } }
      end
      rule 'trigger' do
        received_command Switch1
        run { after(1.second) { logger('timer_for_trigger').info('inside received_command timer') } }
      end
      """
    When I deploy the rule
    And item "Switch1" state is changed to "ON"
    Then It should log "[jsr223.jruby.__timer                ] - inside on_start timer" within 5 seconds
    And  It should log "[jsr223.jruby.timer_for_trigger      ] - inside received_command timer" within 5 seconds
