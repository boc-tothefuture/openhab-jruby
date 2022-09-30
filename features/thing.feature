Feature:  thing
  Rule languages supports interacting with things

  Background:
    Given Clean OpenHAB with latest Ruby Libraries
    And feature 'openhab-binding-astro' installed
    And things:
      | id   | thing_uid | label          | config                | status |
      | home | astro:sun | Astro Sun Data | {"geolocation":"0,0"} | enable |


  Scenario Outline: Rule supports thing status changes for changed and updated
    Given a deployed rule:
      """
      rule 'Execute rule when thing is <trigger>' do
        <trigger> things['astro:sun:home']
        run { |event| logger.info("Thing #{event.uid} status <trigger> to #{event.status}") }
      end
      """
    When thing "astro:sun:home" is disabled
    Then It should log 'Thing astro:sun:home status <trigger> to UNINITIALIZED (DISABLED)' within 5 seconds
    Examples:
      | trigger |
      | changed |
      | updated |

  Scenario Outline: Rule supports thing status changes and updates with specific to states
    Given a deployed rule:
      """
      rule 'Execute rule when thing is changed' do
        <trigger> things['astro:sun:home'], :to => <state>
        run { |event| logger.info("Thing #{event.uid} status <trigger> to #{event.status}") }
      end
      """
    When thing "astro:sun:home" is disabled
    Then It <should> log 'Thing astro:sun:home status <trigger> to UNINITIALIZED (DISABLED)' within 5 seconds
    Examples:
      | state          | trigger | should     |
      | :uninitialized | changed | should     |
      | :unknown       | changed | should not |
      | :uninitialized | updated | should     |
      | :unknown       | updated | should not |

  Scenario Outline: Rule supports thing status changes with specific from states
    Given a deployed rule:
      """
      rule 'Execute rule when thing is changed' do
        changed things['astro:sun:home'], :from => <state>
        run { |event| logger.info("Thing #{event.uid} status changed to #{event.status}") }
      end
      """
    When thing "astro:sun:home" is disabled
    Then It <should> log 'Thing astro:sun:home status changed to UNINITIALIZED' within 5 seconds
    Examples:
      | state    | should     |
      | :online  | should     |
      | :unknown | should not |

  Scenario Outline: Rule supports thing status changes with specific from and to states
    Given a deployed rule:
      """
      rule 'Execute rule when thing is changed' do
        changed things['astro:sun:home'], :from => <from_state>, :to => <to_state>
        run { |event| logger.info("Thing #{event.uid} status changed to #{event.status}") }
      end
      """
    When thing "astro:sun:home" is disabled
    Then It <should> log 'Thing astro:sun:home status changed to UNINITIALIZED' within 5 seconds
    Examples:
      | from_state | to_state       | should     |
      | :online    | :uninitialized | should     |
      | :unknown   | :uninitialized | should not |

  Scenario Outline: Rule supports thing status changes with duration
    Given a deployed rule:
      """
      rule 'Execute rule when thing is changed for 10 seconds' do
        changed things['astro:sun:home'], :to => :uninitialized, for: 10.seconds
        run { |event| logger.info("Thing #{event.uid} status changed to #{event.status}") }
      end
      """
    And thing "astro:sun:home" is enabled
    When thing "astro:sun:home" is disabled
    Then It should log 'Thing astro:sun:home status changed to UNINITIALIZED' within 15 seconds

  Scenario Outline: Rule supports thing status changes with duration
    Given a deployed rule:
      """
      rule 'Execute rule when thing is changed for 20 seconds' do
        changed things['astro:sun:home'], :to => :uninitialized, for: 20.seconds
        run { |event| logger.info("Thing #{event.uid} status changed to #{event.status}") }
      end
      """
    And thing "astro:sun:home" is enabled
    When thing "astro:sun:home" is disabled
    Then if I wait 5 seconds
    And thing "astro:sun:home" is enabled
    Then It should not log 'Thing astro:sun:home status changed to UNINITIALIZED' within 20 seconds
