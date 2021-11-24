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
    Then It should log /\[<level>\s*\].*Test logging at <level>/ within 5 seconds
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
      # Log at file level
      logger.info("Test logging at file level for #{__FILE__}")
      """
    When I deploy the rules file named "log_test.rb"
    Then It should log /\[jsr223\.jruby\.log_test\s*\]/ within 5 seconds

  Scenario: Logging within a top-level timer outputs file as part of log path
    Given code in a rules file
      """
      after(5.ms) { logger.info("Plain logging inside a timer") }
      """
    When I deploy the rules file named "timer_test.rb"
    Then It should log /\[jsr223.jruby.timer_test\s*\]/ within 5 seconds

  Scenario: Logging within a timer inside a rule outputs file as part of log path
    Given code in a rules file
      """
      rule 'a rule' do
        on_start
        run do
          after(5.ms) { logger.info("Plain logging inside a timer inside a rule") }
        end
      end
      """
    When I deploy the rules file named "timer_inside_rule.rb"
    Then It should log /\[jsr223.jruby.timer_inside_rule\s*\]/ within 5 seconds

  Scenario Outline: Logging should include rule name inside a rule
    Given items:
      | type   | name    |
      | Switch | Switch1 |
    And a rule:
      """
      rule 'rule 1' do
        <trigger1>
        run {     logger.info('rule 1 <trigger1>') }
      end
      rule 'rule 2' do
        <trigger1>
        run {     logger.info('rule 2 <trigger1>') }
      end
      rule 'rule 3' do
        <trigger2>
        run {     logger.info('rule 3 <trigger2>') }
      end
      rule 'rule 4' do
        <trigger2>
        run {     logger.info('rule 4 <trigger2>') }
      end
      """
    When I deploy the rules file named "rule_file.rb"
    And item "Switch1" state is changed to "ON"
    Then It should log /\[jsr223.jruby.rule_file.rule_1\s*\] - rule 1 <trigger1>/ within 5 seconds
    And  It should log /\[jsr223.jruby.rule_file.rule_2\s*\] - rule 2 <trigger1>/ within 5 seconds
    And  It should log /\[jsr223.jruby.rule_file.rule_3\s*\] - rule 3 <trigger2>/ within 5 seconds
    And  It should log /\[jsr223.jruby.rule_file.rule_4\s*\] - rule 4 <trigger2>/ within 5 seconds
    Examples:
      | trigger1                 | trigger2                 |
      | on_start                 | received_command Switch1 |
      | received_command Switch1 | on_start                 |

  Scenario Outline: Logging should include rule name inside a guard
    Given items:
      | type   | name    |
      | Switch | Switch1 |
    And a rule:
      """
      rule 'rule 1' do
        <trigger1>
        only_if { logger.info('guard 1 <trigger1>'); true }
        run {     logger.info('rule  1 <trigger1>') }
      end
      rule 'rule 2' do
        <trigger1>
        only_if { logger.info('guard 2 <trigger1>'); true }
        run {     logger.info('rule  2 <trigger1>') }
      end
      rule 'rule 3' do
        <trigger2>
        only_if { logger.info('guard 3 <trigger2>'); true }
        run {     logger.info('rule  3 <trigger2>') }
      end
      rule 'rule 4' do
        <trigger2>
        only_if { logger.info('guard 4 <trigger2>'); true }
        run {     logger.info('rule  4 <trigger2>') }
      end
      """
    When I deploy the rules file named "rule_file.rb"
    And item "Switch1" state is changed to "ON"
    Then It should log /\[jsr223.jruby.rule_file.rule_1\s*\] - guard 1 <trigger1>/ within 5 seconds
    And  It should log /\[jsr223.jruby.rule_file.rule_2\s*\] - guard 2 <trigger1>/ within 5 seconds
    And  It should log /\[jsr223.jruby.rule_file.rule_3\s*\] - guard 3 <trigger2>/ within 5 seconds
    And  It should log /\[jsr223.jruby.rule_file.rule_4\s*\] - guard 4 <trigger2>/ within 5 seconds
    Examples:
      | trigger1                 | trigger2                 |
      | on_start                 | received_command Switch1 |
      | received_command Switch1 | on_start                 |

  Scenario: Logging can use a custom suffix
    Given a rule:
      """
      rule 'on start' do
        on_start
        run { after(1.second) { logger('custom_log').info('inside on_start timer') } }
      end

      logger('custom_top').info('outside a rule')
      """
    When I deploy the rules file named "rule_file.rb"
    And item "Switch1" state is changed to "ON"
    Then It should log /\[jsr223.jruby.rule_file.custom_log\s*\] - inside on_start timer/ within 5 seconds
    Then It should log /\[jsr223.jruby.rule_file.custom_top\s*\] - outside a rule/ within 5 seconds
