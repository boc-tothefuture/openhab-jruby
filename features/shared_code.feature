Feature: shared_code
  Rule language generic support

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario: Call function from rule
    Given code in a shared file named "shared_file.rb"
      """
      def shared_function
        logger.info("Shared Function Test")
      end
      """
    Given a rule
      """
      require "shared_file"

      shared_function
      """
    When I deploy the rules file
    Then It should log 'Shared Function Test' within 5 seconds
