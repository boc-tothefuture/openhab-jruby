Feature:  Rule languages supports OpenHAB transformations

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario: Transform using explicit transform invokation
    Given a map transformation named "AlarmModes.map":
      """
      14=Arming Away
      """
    And code in a rules file
      """
      text = Transformation.transform('MAP','AlarmModes.map',14)
      logger.info("#{test} is 14")
      """
    When I deploy the rule
    Then It should log 'Arming Away is 14' within 10 seconds

  Scenario: Transform using implicit transform
    Given a map transformation named "AlarmModes.map":
      """
      14=Arming Away
      """
    And code in a rules file
      """
      text = AlarmModes.map(14)
      text = AlarmModes[14]
      logger.info("#{test} is 14")
      """
    When I deploy the rule
    Then It should log 'Arming Away is 14' within 10 seconds

  Scenario: Implicit transform inside rule creation
    Given items:
      | type   | name       | label      |
      | Number | Alarm_Mode | Alarm Mode |
    And a map transformation named "AlarmModes.map":
      """
      10=Away
      14=Arming Away
      """
    And a deployed rule:
      """
      rule 'Execute rule when item is changed to specific number using map transform' do
        changed Alarm_Mode, to: AlarmModes.map(["Away","Arming Away"])
        triggered { |item| logger.info("Alarm Mode Updated #{AlarmModes.map(item)}")}
      end
      """
    When item "Alarm_Mode" state is changed to "10"
    Then It should log 'Alarm Mode Updated to Away' within 5 seconds