@conf_files
Feature:  watch
  Rule languages supports watching directories and files

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario Outline: Watch supports directories
    Given a file in subdirectory 'foo' of conf named 'bar'
    And a file in subdirectory 'foo' of conf named 'baz'
    And a deployed rule:
      """
      rule 'watch directory' do
        watch OpenHAB.conf_root + 'foo'
        run { |event| logger.info("#{event.path.basename} - #{event.type}") }
      end
      """
    When I <action> a file in subdirectory 'foo' of conf named '<file>'
    Then It should log '<log>' within 5 seconds
    Examples:
      | action | file | log            |
      | create | qux  | qux - created  |
      | delete | bar  | bar - deleted  |
      | modify | baz  | baz - modified |

  Scenario Outline: Watch supports globs
    Given a file in subdirectory 'foo' of conf named 'bar.erb'
    And a file in subdirectory 'foo' of conf named 'bar'
    And a deployed rule:
      """
      rule 'watch directory' do
        watch OpenHAB.conf_root/'foo', glob: '*.erb'
        run { |event| logger.info("#{event.path.basename} - #{event.type}") }
      end
      """
    When I <action> a file in subdirectory 'foo' of conf named '<file>'
    Then It <should> log '<log>' within 5 seconds
    Examples:
      | action | file    | should     | log                |
      | create | qux.erb | should     | qux.erb - created  |
      | delete | bar.erb | should     | bar.erb - deleted  |
      | modify | baz.erb | should     | baz.erb - modified |
      | create | qux     | should not | qux - created      |
      | delete | bar     | should not | qux - deleted      |
      | modify | baz     | should not | baz - modified     |

  Scenario Outline: Watch supports a single file
    Given a file in subdirectory 'foo' of conf named 'bar'
    And a file in subdirectory 'foo' of conf named 'baz'
    And a deployed rule:
      """
      rule 'watch file' do
        watch OpenHAB.conf_root + 'foo/bar'
        run { |event| logger.info("#{event.path.basename} - #{event.type}") }
      end
      """
    When I <action> a file in subdirectory 'foo' of conf named '<file>'
    Then It <should> log '<log>' within 5 seconds
    Examples:
      | action | file | should     | log            |
      | modify | bar  | should     | bar - modified |
      | delete | bar  | should     | bar - deleted  |
      | modify | baz  | should not | baz - modified |
      | delete | baz  | should not | baz - deleted  |

  Scenario Outline: Watch supports creation for single file
    Given a subdirectory 'foo' of conf
    And a deployed rule:
      """
      rule 'watch file' do
        watch OpenHAB.conf_root + 'foo/bar'
        run { |event| logger.info("#{event.path.basename} - #{event.type}") }
      end
      """
    When I <action> a file in subdirectory 'foo' of conf named '<file>'
    Then It <should> log '<log>' within 5 seconds
    Examples:
      | action | file | should     | log           |
      | create | bar  | should     | bar - created |
      | create | baz  | should not | baz - created |


  Scenario Outline: Watch supports globs in path
    Given a file in subdirectory 'foo' of conf named 'bar.erb'
    And a file in subdirectory 'foo' of conf named 'bar'
    And a deployed rule:
      """
      rule 'watch directory' do
        watch OpenHAB.conf_root + 'foo/*.erb'
        run { |event| logger.info("#{event.path.basename} - #{event.type}") }
      end
      """
    When I <action> a file in subdirectory 'foo' of conf named '<file>'
    Then It <should> log '<log>' within 5 seconds
    Examples:
      | action | file    | should     | log                |
      | create | qux.erb | should     | qux.erb - created  |
      | delete | bar.erb | should     | bar.erb - deleted  |
      | modify | baz.erb | should     | baz.erb - modified |
      | create | qux     | should not | qux - created      |
      | delete | bar     | should not | qux - deleted      |
      | modify | baz     | should not | baz - modifie      |

  Scenario Outline: Watch can limit event triggers
    Given a file in subdirectory 'foo' of conf named 'bar'
    And a deployed rule:
      """
      rule 'watch directory' do
        watch OpenHAB.conf_root + 'foo', for: <event_type>
        run { |event| logger.info("#{event.path.basename} - #{event.type}") }
      end
      """
    When I <action> a file in subdirectory 'foo' of conf named '<file>'
    Then It <should> log '<log>' within 5 seconds
    Examples:
      | action | file | event_type            | should     | log           |
      | delete | bar  | :deleted              | should     | bar - deleted |
      | delete | bar  | [:deleted, :modified] | should     | bar - deleted |
      | delete | bar  | :modified             | should not | bar - deleted |
      | delete | bar  | [:modified,:created]  | should not | bar - deleted |