Feature: rule_language
  Rule language generic support

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario: Library version should be logged on start
    Given code in a rules file:
      """
      """
    When I deploy the rules file
    Then It should log 'OpenHAB JRuby Scripting Library Version' within 5 seconds
    And It should log 'OpenHAB ready for rule processing' within 5 seconds

  @log_level_changed
  Scenario: Native java exceptions are handled during rule creation
    Given log level INFO
    And code in a rules file
      """
      def test
        java.lang.Integer.parse_int('k')
      end

      rule 'test' do
        test
      end
      """
    When I deploy the rules file
    Then It should log 'For input string: "k" (Java::JavaLang::NumberFormatException)' within 5 seconds
    And It should log 'In Rule: test' within 5 seconds
    And It should log "RUBY.test" within 5 seconds
    And It should log "RUBY.<main>" within 5 seconds
