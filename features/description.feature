Feature:  Rule languages supports description feature

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario: Set the rule description
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
