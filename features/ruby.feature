Feature:  ruby
  Support for various types of ruby variables

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  @wip
  Scenario: Instance variables are available with a rule
    Given a rule
      """
      rule 'set variable' do
        on_start
        run { @foo = 'bar' }
        run { logger.info("@Foo is #{@foo}") }
      end
      """
    When I deploy the rule
    Then It should log 'Foo is bar' within 5 seconds

  @wip
  Scenario: Rule variables are available between rules
    Given a rule
      """
      rule 'set variable' do
        on_start
        run do
          rule_var { @foo = 'bar' }
          logger.info("@Foo set to #{ rule_var { @foo } }")
        end
      end

      rule 'read variable' do
        on_start
        delay 2.seconds
        run do
         logger.info("@Foo is defined: #{ rule_var { instance_variable_defined?("@foo")} }")
        end
      end
      """
    When I deploy the rule
    Then It should log 'Foo is defined: true' within 5 seconds

  @wip
  Scenario: Instance variables are not shared between rules files
    Given a deployed rule:
      """
      rule 'set variable' do
        on_start
        run do
          rule_var { @foo = 'bar' }
          logger.info("#{rule_var{self.class.name}}")
          logger.info("#{rule_var{object_id}}")
          logger.info("@Foo set to #{ rule_var { @foo } }")
        end
      end
      """
    And a rule:
      """"
      rule 'read variable' do
        on_start
        delay 2.seconds
        run do
         logger.info("#{rule_var{self.class.name}}")
         logger.info("#{rule_var{object_id}}")
         logger.info("@Foo is defined: #{ rule_var { instance_variable_defined?("@foo")} }")
        end
      end
      """
    When I deploy the rule
    Then It should log 'Foo is defined: false' within 5 seconds

  Scenario: Works on JRuby 9.3.4.0
    Given a rule
      """
      logger.info "JRuby Version #{RUBY_ENGINE_VERSION}"
      """
    When I deploy the rule
    Then It should log 'Ruby Version 9.3.4.0' within 5 seconds
