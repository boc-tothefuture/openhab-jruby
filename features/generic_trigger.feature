Feature:  generic_trigger
  Rule languages supports generic trigger features

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario: An update using the generic trigger feature
    Given items:
      | type   | name    |
      | Switch | Switch1 |
    And a deployed rule:
      """
      rule 'Execute rule when item is updated to any value' do
        trigger 'core.ItemStateUpdateTrigger', itemName: 'Switch1'
        run { logger.info("Switch1 Updated") }
      end
      """
    When item "Switch1" state is changed to "ON"
    Then It should log 'Switch1 Updated' within 5 seconds

  Scenario: Use pidcontroller trigger
    Given items:
      | type   | name         |
      | Number | InputItem    |
      | Number | SetPointItem |
    And feature 'openhab-automation-pidcontroller' installed
    And a deployed rule:
      """
      rule 'Execute rule when item is updated to any value' do
        trigger 'pidcontroller.trigger',
          input: InputItem.name,
          setpoint: SetPointItem.name,
          kp: 10,
          ki: 10,
          kd: 10,
          kdTimeConstant: 1,
          loopTime: 1000

        run do |event|
          logger.info("PID Command: #{event.command}")
        end
      end
      """
    When item "InputItem" state is changed to "5"
    And item "SetPointItem" state is changed to "10"
    Then It should log 'PID Command: ' within 5 seconds
    And I remove the rules file
# Remove the rules file to stop the rule from continuing to run

