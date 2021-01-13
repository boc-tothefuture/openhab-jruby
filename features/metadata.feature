Feature:  Items support accessing metadata

  Background:
    Given Clean OpenHAB with latest Ruby Libraries
    And items:
      | type   | name       |
      | Switch | TestSwitch |

  Scenario: User can access item metadata using hash like accessors
    Given metadata added to "TestSwitch" in namespace "test":
      """
      {
      "value": "foo",
      "config": {
        "bar": 'baz',
        "qux": 'quux'
      }
      }
      """
    And code in a rules file:
      """
      logger.info("TestSwitch value for namespace test is: #{TestSwitch.meta['test'].value}")
      logger.info("TestSwitch value for config bar is: #{TestSwitch.meta['test']['bar']}")
      logger.info("TestSwitch value for config qux is: #{TestSwitch.meta['test'].dig('qux')}")
      """
    When I deploy the rules file
    Then It should log 'TestSwitch value for namespace test is: foo' within 5 seconds
    And It should log 'TestSwitch value for config bar is: baz' within 5 seconds
    And It should log 'TestSwitch value for config qux is: quux' within 5 seconds

  Scenario: User can modify item metadata using hash like setters
    Given metadata added to "TestSwitch" in namespace "test":
      """
      {
      "value": "foo",
      "config": {
        "bar": 'baz',
        "qux": 'quux'
      }
      }
      """
    And code in a rules file:
      """
      TestSwitch.meta['test']['bar']='corge'
      """
    When I deploy the rules file
    Then It should log 'TestSwitch value for namespace test is: foo' within 5 seconds