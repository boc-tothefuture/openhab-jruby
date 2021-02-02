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

  # Waiting on merge of PR
  @wip
  Scenario: Logging outputs file as part of log path
    Given code in a rules file
      """
      # Log at a level
      logger.info("Test logging at for #{__FILE__}")

      rule 'log test' do
        on_start
        run { logger.info('Log Test') }
      end

      """
    When I deploy the rules file named "log_test.rb"
    Then It should log 'jsr223.jruby.log_test' within 5 seconds