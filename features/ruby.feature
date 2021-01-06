Feature:  Openhab Gem Support

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

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

