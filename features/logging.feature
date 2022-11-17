Feature:  logging
  Provides a bridge to OpenHAB Logging

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario: Logger works after requiring third party gems
    Given a rule
      """
      gemfile do
        source 'https://rubygems.org'
        gem 'httparty'
      end

      logger.info("OpenHAB Rules!")
      """
    When I deploy the rules file
    Then It should log 'OpenHAB Rules!' within 5 seconds
