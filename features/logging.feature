Feature:  logging
  Provides a bridge to OpenHAB Logging

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario Outline: Logging supports trace, debug, warn, info error
    Given code in a rules file
      """
      # Log at a level
      logger.<level>('Test logging at <level>')
      """
    When I deploy the rules file named "log_test.rb"
    Then It should log 'Test logging at <level>' within 5 seconds
    Examples:
      | level |
      | trace |
      | debug |
      | warn  |
      | info  |
      | error |

  Scenario: Logging accepts block
    Given code in a rules file
      """
      # Log at a level
      logger.error { "Error Message in Block" }
      """
    When I deploy the rules file
    Then It should log 'Error Message in Block' within 5 seconds

  Scenario: Logging uses file name when not logging in a rule
    Given code in a rules file
      """
      # Log at a level
      logger.info("Hello World!")
      """
    When I deploy the rules file named "foo_bar.rb"
    Then It should log only "Hello World!" at level "INFO" from 'jsr223.jruby.foo_bar' within 5 seconds


  Scenario: Logging should include rule name inside a rule
    Given code in a rules file
      """
      rule 'log test' do
        on_start
        run { logger.info('Log Test') }
      end

      """
    When I deploy the rules file named "log_rule_test.rb"
    Then It should log only "Log Test" at level "INFO" from 'jsr223.jruby.log_rule_test.log_test' within 5 seconds

  Scenario: Methods called by a rule have the rule file and name in their log name
    Given code in a rules file
      """
      def log_foo
        logger.info('Foo')
      end

      rule 'log test' do
        on_start
        run { log_foo }
      end

      """
    When I deploy the rules file named "log_file.rb"
    Then It should log only "Foo" at level "INFO" from 'jsr223.jruby.log_file.log_test' within 5 seconds

  Scenario: Logs in after blocks (timers) should have file and rule name in log prefix
    Given code in a rules file
      """
      rule 'log test' do
        on_start
        run do 
          after 1.second do
            logger.info('Bar')
          end
        end
      end
      """
    When I deploy the rules file named "log_file.rb"
    Then It should log only "Bar" at level "INFO" from 'jsr223.jruby.log_file.log_test' within 5 seconds

  Scenario: Logs in blocks after trigger delays should have file and rule name in log prefix
   Given items:
    | type   | name | state  |
    | Number | Foo  | 0      |
    Given a rule:
      """
      rule 'log test' do
        changed Foo, to: 5, for: 3.seconds
        run do 
          logger.info('Baz')
        end
      end
      """
    When I deploy the rules file named "log_file.rb"
    And item "Foo" state is changed to "5"
    Then It should log only "Baz" at level "INFO" from 'jsr223.jruby.log_file.log_test' within 8 seconds


