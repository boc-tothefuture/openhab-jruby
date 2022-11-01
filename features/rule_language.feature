Feature: rule_language
  Rule language generic support

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario: Rules support description
    Given a rule:
      """
      rule 'Test rule' do
        description 'This is the rule description'
        on_start
        run {}
      end
      """
    When I deploy the rule
    Then The rule 'Test rule' should have 'This is the rule description' as its description

  Scenario: Rules support tags
    Given a rule:
      """
      myrule = rule 'Test rule' do
        tags "tag1", "tag2", Semantics::LivingRoom
        on_start
        run {}
      end

      logger.info myrule.tags.to_a.sort
      """
    When I deploy the rule
    Then It should log '["LivingRoom", "tag1", "tag2"]' within 5 seconds

  Scenario: Call function from rule
    Given code in a rules file
      """
      def outer_function(message)
        logger.info("Outer Function #{message}")
      end

      rule 'Test Outer Function' do
        on_start
        run { outer_function("Test123") }
      end
      """
    When I deploy the rules file
    Then It should log 'Outer Function Test123' within 5 seconds

  Scenario: Iterate over group using array methods directly on group object
    Given group "GarageDoors"
    And items:
      | type    | name      | label      | group       | state  |
      | Contact | LeftDoor  | Left Door  | GarageDoors | OPEN   |
      | Contact | RightDoor | Right Door | GarageDoors | CLOSED |
    And code in a rules file
      """
      open_doors = GarageDoors.select(&:open?)
      open_doors.each { | door | logger.warn("Garage Door #{door.name} is OPEN") }
      """
    When I deploy the rules file
    Then It should log 'Garage Door Left Door is OPEN' within 5 seconds

  Scenario: Number ranges should work with dimmer values
    Given items:
      | type   | name       | label         | state |
      | Dimmer | TestDimmer | Dimmer Switch | 55    |
    And code in a rules file
      """
      case TestDimmer
      when 0...50
       logger.info("#{TestDimmer.name} Less than 50")
      when 50..100
       logger.info("#{TestDimmer.name} More than 50")
      else
       logger.info("#{TestDimmer} Not matched")
      end
      """
    When I deploy the rules file
    Then It should log 'More than 50' within 5 seconds

  Scenario: Grep should work on Items by ItemType
    Given items:
      | type   | name       | label         | state |
      | Dimmer | TestDimmer | Dimmer Switch | 55    |
    And code in a rules file
      """
      items.grep(Dimmer)
           .each { |item| logger.info("Found #{item.label}")}
      """
    When I deploy the rules file
    Then It should log 'Found Dimmer Switch' within 5 seconds

  Scenario Outline: Rule supports executing different block if guards are not satisfied
    Given items:
      | type   | name       | state |
      | Switch | TestSwitch | ON    |
    And a rule
      """
      rule 'Execute otherwise if guard is not satisfied' do
        on_start
        run { TestSwitch << ON }
        otherwise { TestSwitch << OFF }
        only_if { <condition> }
      end
      """
    When I deploy the rule
    Then "TestSwitch" should be in state "<outcome>" within 5 seconds
    Examples: Check different conditions
      | condition | outcome |
      | true      | ON      |
      | false     | OFF     |


  Scenario: Terse rules are supported
    Given items:
      | type   | name       | state |
      | Switch | TestSwitch | OFF   |
    And a rule
      """
      changed TestSwitch do
        logger.trace("Rule {#{OpenHAB::DSL::Rules::Rule.script_rules.first.name}}")
      end
      """
    When I deploy the rule
    And item "TestSwitch" state is changed to "ON"
    Then It should log 'Rule {TestSwitch changed}' within 5 seconds

  Scenario Outline: Triggers return an OpenHAB TriggerImpl object
    Given items:
      | type   | name       |
      | Number | Alarm_Mode |
    And a rule
      """
      rule 'Check trigger return value' do
        trigger = <trigger> Alarm_Mode
        logger.info("<trigger> returns #{trigger&.first&.class}")
        run { }
      end
      """
    When I deploy the rules file
    Then It should log '<trigger> returns Java::OrgOpenhabCoreAutomationInternal::TriggerImpl' within 5 seconds
    Examples:
      | trigger          |
      | updated          |
      | changed          |
      | received_command |

  Scenario: Rule logs a warning and isn't created if it contains no execution blocks
    Given a rule
      """
      rule 'No execution blocks' do
        on_start
      end
      """
    When I deploy the rule
    Then It should log 'has no execution blocks, not creating rule' within 5 seconds

  Scenario: Library version should be logged on start
    Given code in a rules file:
      """
      """
    When I deploy the rules file
    Then It should log 'OpenHAB JRuby Scripting Library Version' within 5 seconds

  Scenario: Library waits until automation manager is ready before processing rules
    Given code in a rules file:
      """
      """
    When I deploy the rules file
    Then It should log 'OpenHAB ready for rule processing' within 5 seconds

  @log_level_changed
  Scenario Outline: Errors in blocks are logged with stack trace and exits rule
    Given log level INFO
    And code in a rules file
      """
      def test
        test2
      end

      def test2
        raise 'Something is wrong'
      end

      rule 'test' do
        on_start
        <block> { test }
        delay 1.seconds
        run { logger.info('This one works!') }
      end
      """
    When I deploy the rules file
    Then It should log 'Something is wrong (RuntimeError)' within 5 seconds
    And It should log 'In rule: test' within 5 seconds
    And It should log "in `test2'" within 5 seconds
    And It should log "in `test'" within 5 seconds
    And It should log "in `block in <main>'" within 5 seconds
    And It should log "in `<main>'" within 5 seconds
    But It should not log 'This one works!' within 10 seconds
    Examples: Checks different block types
      | block   |
      | run     |
      | only_if |
      | not_if  |

  @log_level_changed
  Scenario: Native java exceptions are handled during rule execution
    Given log level INFO
    And code in a rules file
      """
      def test
        Java::JavaLang::Integer.parseInt('k')
      end

      rule 'test' do
        on_start
        run { test }
      end
      """
    When I deploy the rules file
    Then It should log 'For input string: "k" (Java::JavaLang::NumberFormatException)' within 5 seconds
    And It should log 'In rule: test' within 5 seconds
    And It should log "RUBY.test" within 5 seconds
    And It should log "RUBY.<main>" within 5 seconds

  @log_level_changed
  Scenario: Native java exceptions are handled during rule creation
    Given log level INFO
    And code in a rules file
      """
      def test
        Java::JavaLang::Integer.parseInt('k')
      end

      rule 'test' do
        test
      end
      """
    When I deploy the rules file
    Then It should log 'For input string: "k" (Java::JavaLang::NumberFormatException)' within 5 seconds
    And It should log 'In rule: test' within 5 seconds
    And It should log "RUBY.test" within 5 seconds
    And It should log "RUBY.<main>" within 5 seconds

  Scenario: OpenHAB config directory is available
    Given code in a rules file:
      """
        logger.info("Conf #{OpenHAB.conf_root}")
        logger.info("Conf directory is #{OpenHAB.conf_root.each_filename.to_a.last(2).join('/')}")
      """
    When I deploy the rules file
    Then It should log 'Conf directory is openhab/conf' within 5 seconds

  Scenario: Rule method returns the rule object with Rule UID
    Given code in a rules file:
      """
      rule = rule 'test' do
        on_start
        run { logger.info('inside rule') }
      end
      logger.info "Rule UID: '#{rule.uid}'"
      """
    When I deploy the rules file
    Then It should log /Rule UID: '.+'/ within 5 seconds

  Scenario: DSL methods don't leak into other objects
    Given a raw rule:
      """
      original_methods = Class.methods

      require 'openhab/dsl'

      leaked_methods = (Class.methods - original_methods).sort
      logger.info "Leaked methods: #{leaked_methods}"
      """
    When I deploy the rules file
    Then It should log "Leaked methods: []" within 5 seconds

  @wip
  Scenario: Check constants introduced by the library
    Given a raw rule:
      """
      def all_constants
        Object.ancestors.map(&:constants).concat(Object.constants).flatten.uniq.sort
      end

      original_constants = all_constants

      require 'openhab/dsl'

      added_constants = (all_constants - original_constants).sort

      # added_constants.each {|s| logger.info "#{s} => #{Object.const_get(s).class.name}" }
      logger.info "Added constants: #{added_constants}"
      logger.info "OK"
      """
    When I deploy the rules file
    Then It should log "OK" within 5 seconds
