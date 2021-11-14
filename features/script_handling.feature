Feature:  script_handling
  script_loaded and script_unloaded are supported

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario: proc passed to script_loaded executes after the the main script
    Given a rule
      """
      @counter = 0

      def run_me
        logger.info("run_me counter: #{@counter}")
      end

      script_loaded { run_me }

      @counter = 1

      """
    When I deploy the rule
    Then It should log 'run_me counter: 1' within 5 seconds

  Scenario Outline: proc passed to script_unloaded will execute when the script has been unloaded
    Given a rule
      """
      @counter = 0

      def run_me
        logger.info("<name> counter: #{@counter}")
      end

      script_unloaded { run_me }

      rule 'unload_test' do
        on_start
        delay 5.seconds
        run { @counter = 2 }
      end
      """
    When I deploy the rule
    And I remove the rules file
    Then It should log '<name> counter: 0' within 10 seconds
    Examples:
      | name  |
      | test1 |
      | test2 |
      | test3 |