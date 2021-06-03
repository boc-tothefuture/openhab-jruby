Feature: rule_language
  Rule language generic support

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

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
      open_doors.each { | door | logger.warn("Garage Door #{door.id} is OPEN") }
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
       logger.info("#{TestDimmer.id} Less than 50")
      when 50..100
       logger.info("#{TestDimmer.id} More than 50")
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
  Scenario: Errors in a run block is logged with stack trace and exits rule
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
        run { test }
        delay 5.seconds
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

  @log_level_changed
  Scenario: Native java exceptions are handled
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
