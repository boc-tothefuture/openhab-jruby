Feature:  gem_install
  OpenHAB JRuby helper library can be installed as a Gem

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  @reset_library
  Scenario: Install OpenHAB helper library
    Given OpenHAB is stopped
    And GEM_HOME is empty
    And a services template filed named "jruby.cfg"
      """
      org.openhab.automation.jrubyscripting:gem_home=<%= gem_home %>
      org.openhab.automation.jrubyscripting:gems=openhab-scripting=~>3.0
      """
    And code in a rules file:
      """
      logger.info("OpenHAB helper library is at #{OpenHAB::VERSION}")
      """
    When I start OpenHAB
    Then It should log 'Installing Gem: openhab-scripting' within 120 seconds
    And I deploy the rules file
    Then It should log 'OpenHAB helper library is at' within 160 seconds

