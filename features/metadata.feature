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
      logger.info("TestSwitch value for config bar is: #{TestSwitch.meta['test']['bar']}")
      """
    When I deploy the rules file
    Then It should log 'TestSwitch value for config bar is: corge' within 5 seconds

  Scenario: User can add item metadata configuration using hash like setters
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
      TestSwitch.meta['test']['bam']='corge'
      logger.info("TestSwitch value for config bam is: #{TestSwitch.meta['test']['bam']}")
      """
    When I deploy the rules file
    Then It should log 'TestSwitch value for config bam is: corge' within 5 seconds

  Scenario: User can modify item metadata value
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
      TestSwitch.meta['test']='corge'
      logger.info("TestSwitch value for namespace test is: '#{TestSwitch.meta['test'].value}' #{TestSwitch.meta['test']}")
      """
    When I deploy the rules file
    Then It should log "TestSwitch value for namespace test is: 'corge' {}" within 5 seconds

  Scenario: User can modify item metadata configuration
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
      TestSwitch.meta['test']= { 'x' => 'y' }
      logger.info("TestSwitch value for namespace test is: \"#{TestSwitch.meta['test'].value}\" #{TestSwitch.meta['test']}")
      """
    When I deploy the rules file
    Then It should log 'TestSwitch value for namespace test is: "" {"x"=>"y"}' within 5 seconds

  Scenario: User can modify item metadata value and configuration
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
      TestSwitch.meta['test']= 'bit', { 'x' => 'y' }
      logger.info("TestSwitch value for namespace test is: \"#{TestSwitch.meta['test'].value}\" #{TestSwitch.meta['test']}")
      """
    When I deploy the rules file
    Then It should log 'TestSwitch value for namespace test is: "bit" {"x"=>"y"}' within 5 seconds

  Scenario: User can delete item metadata configuration
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
      logger.info("TestSwitch value for config test:bar is: \"#{TestSwitch.meta['test']['bar']}\" \"#{TestSwitch.meta['test']['bar'].nil?}\"")
      TestSwitch.meta['test'].delete 'bar'
      logger.info("TestSwitch value for config test:bar is: \"#{TestSwitch.meta['test']['bar']}\" \"#{TestSwitch.meta['test']['bar'].nil?}\"")
      """
    When I deploy the rules file
    Then It should log 'TestSwitch value for config test:bar is: "baz" "false' within 5 seconds
    And It should log 'TestSwitch value for config test:bar is: "" "true"' within 5 seconds

  Scenario: User can add item metadata namespace
    Given code in a rules file:
      """
      TestSwitch.meta['new']= 'foo', { 'bar' => 'baz' }
      logger.info("TestSwitch value for namespace new is: \"#{TestSwitch.meta['new'].value}\" #{TestSwitch.meta['new']}")
      """
    When I deploy the rules file
    Then It should log 'TestSwitch value for namespace new is: "foo" {"bar"=>"baz"}' within 5 seconds

  Scenario: User can check for inexistence of item metadata
    Given code in a rules file:
      """
      TestSwitch.meta.key? 'test'
      logger.info("TestSwitch has metadata namespace test? '#{TestSwitch.meta.key? 'test'}'")
      """
    When I deploy the rules file
    Then It should log "TestSwitch has metadata namespace test? 'false'" within 5 seconds

  Scenario: User can delete item metadata
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
      logger.info("TestSwitch has metadata namespace test? '#{TestSwitch.meta.key? 'test'}'")
      TestSwitch.meta.delete 'test'
      logger.info("TestSwitch does not have metadata namespace test? '#{!TestSwitch.meta.key? 'test'}'")
      """
    When I deploy the rules file
    Then It should log "TestSwitch has metadata namespace test? 'true'" within 5 seconds
    And It should log "TestSwitch does not have metadata namespace test? 'true'" within 5 seconds

  Scenario: User can enumerate all item metadata namespaces
    Given metadata added to "TestSwitch" in namespace "test":
      """
      {
      "value": "foo",
      "config": { "bar": 'baz' }
      }
      """
    And metadata added to "TestSwitch" in namespace "second":
      """
      {
      "value": "boo",
      "config": { "moo": 'goo' }
      }
      """
    And code in a rules file:
      """
      TestSwitch.meta.each do |namespace, value, config|
      logger.info("TestSwitch namespace #{namespace} is: \"#{value}\" #{config}")
      end
      """
    When I deploy the rules file
    Then It should log 'TestSwitch namespace test is: "foo" {"bar"=>"baz"}' within 5 seconds
    And It should log 'TestSwitch namespace second is: "boo" {"moo"=>"goo"}' within 5 seconds



  Scenario: User can delete all item metadata namespaces
    Given metadata added to "TestSwitch" in namespace "test":
      """
      {
      "value": "foo",
      "config": { "bar": 'baz' }
      }
      """
    And metadata added to "TestSwitch" in namespace "second":
      """
      {
      "value": "boo",
      "config": { "moo": 'goo' }
      }
      """
    And code in a rules file:
      """
      TestSwitch.meta.clear
      logger.info("TestSwitch namespace test is: \"#{TestSwitch.meta['test']&.value}\" \"#{TestSwitch.meta['test']}\"")
      logger.info("TestSwitch namespace second is: \"#{TestSwitch.meta['second']&.value}\" \"#{TestSwitch.meta['second']}\"")
      """
    When I deploy the rules file
    Then It should log 'TestSwitch namespace test is: "" ""' within 5 seconds
    And It should log 'TestSwitch namespace second is: "" ""' within 5 seconds






