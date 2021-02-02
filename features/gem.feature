Feature:  gem
  Openhab Gem Support

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario: User can install a gem with bundler
    Given code in a rules file
      """
      gemfile do
        source 'https://rubygems.org'
        gem 'json', require: false
        gem 'nap', '1.1.0', require: 'rest'
      end

      logger.info("The nap gem is at version #{REST::VERSION}")
      """
    When I deploy the rule
    Then It should log 'The nap gem is at version 1.1.0' within 120 seconds

