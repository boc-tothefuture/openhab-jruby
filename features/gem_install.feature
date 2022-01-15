Feature:  gem_install
  OpenHAB JRuby helper library can be installed as a Gem

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  @reset_library
  # This will install the current release version from rubygems.org
  # Running a rule here may cause errors if the new version is not
  # compatible with the release version
  Scenario: Install OpenHAB helper library
    Given OpenHAB is stopped
    And GEM_HOME is empty
    And a services template filed named "jruby.cfg"
      """
      org.openhab.automation.jrubyscripting:gem_home=<%= gem_home %>
      org.openhab.automation.jrubyscripting:gems=openhab-scripting=~>4.0
      org.openhab.automation.jrubyscripting:rubylib=<%= ruby_lib_dir %>
      """
    When I start OpenHAB
    Then It should log 'Installing Gem: openhab-scripting' within 180 seconds

