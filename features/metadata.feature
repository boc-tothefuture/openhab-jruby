Feature:  metadata
  Items support accessing metadata

  Background:
    Given Clean OpenHAB with latest Ruby Libraries
    And items:
      | type   | name        |
      | Switch | TestSwitch  |
      | Switch | TestSwitch2 |

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

  Scenario: Using .config= to assign metadata configuration without overwriting the value
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
      TestSwitch.meta['test'].config = { 'x' => 'y' }
      logger.info("TestSwitch value for namespace test is: \"#{TestSwitch.meta['test'].value}\" #{TestSwitch.meta['test']}")
      """
    When I deploy the rules file
    Then It should log 'TestSwitch value for namespace test is: "foo" {"x"=>"y"}' within 5 seconds

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
      logger.info("Before: TestSwitch value for config test:bar is: \"#{TestSwitch.meta['test']['bar']}\" nil? \"#{TestSwitch.meta['test']['bar'].nil?}\"")
      TestSwitch.meta['test'].delete 'bar'
      logger.info("After: TestSwitch value for config test:bar is: \"#{TestSwitch.meta['test']['bar']}\" nil? \"#{TestSwitch.meta['test']['bar'].nil?}\"")
      """
    When I deploy the rules file
    Then It should log 'Before: TestSwitch value for config test:bar is: "baz" nil? "false' within 5 seconds
    And It should log 'After: TestSwitch value for config test:bar is: "" nil? "true"' within 5 seconds

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
      logger.info("TestSwitch has metadata namespace test after deletion? '#{TestSwitch.meta.key? 'test'}'")
      """
    When I deploy the rules file
    Then It should log "TestSwitch has metadata namespace test? 'true'" within 5 seconds
    And It should log "TestSwitch has metadata namespace test after deletion? 'false'" within 5 seconds

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
      logger.info("TestSwitch namespace #{namespace} is: value=\"#{value}\" config=#{config}")
      end
      """
    When I deploy the rules file
    Then It should log 'TestSwitch namespace test is: value="foo" config={"bar"=>"baz"}' within 5 seconds
    And It should log 'TestSwitch namespace second is: value="boo" config={"moo"=>"goo"}' within 5 seconds



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

  Scenario: Metadata namespaces can be merged with a hash
    Given code in a rules file
      """
      TestSwitch.meta.merge!({"n1"=>["baz",{"foo"=>"bar"}],"n2"=>["boo",{"moo"=>"goo"}]})
      logger.info("TestSwitch n1: value=#{TestSwitch.meta['n1'].value} config=#{TestSwitch.meta['n1']}")
      logger.info("TestSwitch n2: value=#{TestSwitch.meta['n2'].value} config=#{TestSwitch.meta['n2']}")
      """
    When I deploy the rules file
    Then It should log 'TestSwitch n1: value=baz config={"foo"=>"bar"}' within 5 seconds
    Then It should log 'TestSwitch n2: value=boo config={"moo"=>"goo"}' within 5 seconds


  Scenario: Item metadata can be merged with another item's metadata
    Given metadata added to "TestSwitch" in namespace "ts1":
      """
      {
      "value": "foo",
      "config": { "bar": 'baz' }
      }
      """
    And metadata added to "TestSwitch2" in namespace "ts2":
      """
      {
      "value": "boo",
      "config": { "moo": 'goo' }
      }
      """
    And code in a rules file
      """
      TestSwitch.meta.merge! TestSwitch2.meta
      logger.info("TestSwitch ts1: value=#{TestSwitch.meta['ts1'].value} config=#{TestSwitch.meta['ts1']}")
      logger.info("TestSwitch ts2: value=#{TestSwitch.meta['ts2'].value} config=#{TestSwitch.meta['ts2']}")
      """
    When I deploy the rules file
    Then It should log 'TestSwitch ts1: value=foo config={"bar"=>"baz"}' within 5 seconds
    Then It should log 'TestSwitch ts2: value=boo config={"moo"=>"goo"}' within 5 seconds

  Scenario: Dig works on top level metadata namespace
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
      logger.info("TestSwitch value for dig('test') is: #{TestSwitch.meta.dig('test')}")
      logger.info("TestSwitch value for dig('test', 'qux') is: #{TestSwitch.meta.dig('test', 'qux')}")
      logger.info("TestSwitch value for dig('nonexistent', 'qux') is nil?: #{TestSwitch.meta.dig('nonexistent', 'qux').nil?}")
      logger.info("TestSwitch value for dig('test', 'nonexistent') is nil?: #{TestSwitch.meta.dig('test', 'nonexistent').nil?}")
      """
    When I deploy the rules file
    Then It should log "TestSwitch value for dig('test') is: foo" within 5 seconds
    And It should log "TestSwitch value for dig('test', 'qux') is: quux" within 5 seconds
    And It should log "TestSwitch value for dig('nonexistent', 'qux') is nil?: true" within 5 seconds
    And It should log "TestSwitch value for dig('test', 'nonexistent') is nil?: true" within 5 seconds

  Scenario Outline: Item assigned to metadata value
    Given items:
      | type   | name   | state   |
      | <type> | <item> | <state> |
    And code in a rules file:
      """
      TestSwitch.meta['test'] = <item>
      logger.info("TestSwitch metadata value for 'test' is: #{TestSwitch.meta['test'].value}")
      """
    When I deploy the rules file
    Then It should log "TestSwitch metadata value for 'test' is: <state>" within 5 seconds
    Examples: using different item types
      | type               | item     | state  |
      # | Color | Col_Item | 10,20,30 | # TODO: COLOR Item is not yet properly implemented to return its values
      | Contact            | Ctc_Item | CLOSED |
      | Dimmer             | Dim_Item | 60     |
      | Number             | Num_Item | 1.12   |
      | Number:Temperature | Tmp_Item | 12 °C  |
      | Rollershutter      | Rol_Item | 33     |
      | String             | Str_Item | foo    |
      | Switch             | Swc_Item | ON     |

  Scenario: Metadata works for groups
    Given group "TestGroup"
    And metadata added to "TestGroup" in namespace "test":
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
      logger.info("TestGroup value for namespace test is: #{TestGroup.meta['test'].value}")
      logger.info("TestGroup value for config bar is: #{TestGroup.meta['test']['bar']}")
      logger.info("TestGroup value for config qux is: #{TestGroup.meta['test'].dig('qux')}")
      """
    When I deploy the rules file
    Then It should log 'TestGroup value for namespace test is: foo' within 5 seconds
    And It should log 'TestGroup value for config bar is: baz' within 5 seconds
    And It should log 'TestGroup value for config qux is: quux' within 5 seconds

  Scenario: Set value and preserve existing config, or create a new namespace
    Given metadata added to "TestSwitch" in namespace "test":
      """
      {
        "value": "foo",
        "config": {
          'bar': 'baz'
        }
      }
      """
    And code in a rules file:
      """
      TestSwitch.meta['test'] = 'val', TestSwitch.meta['test']
      logger.info("TestSwitch value for namespace test value=#{TestSwitch.meta['test'].value} config=#{TestSwitch.meta['test']}")

      TestSwitch.meta['test2'] = 'val2', TestSwitch.meta['test2']
      logger.info("TestSwitch value for namespace test2 value=#{TestSwitch.meta['test2'].value} config=#{TestSwitch.meta['test2']}")
      """
    When I deploy the rules file
    Then It should log 'TestSwitch value for namespace test value=val config={"bar"=>"baz"}' within 5 seconds
    And It should log 'TestSwitch value for namespace test2 value=val2 config={}' within 5 seconds

  Scenario: User can assign the config of one namespace to another
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
      TestSwitch.meta['test'].config = TestSwitch.meta['second']
      logger.info("TestSwitch namespace test is: \"#{TestSwitch.meta['test']&.value}\" #{TestSwitch.meta['test']}")
      """
    When I deploy the rules file
    Then It should log 'TestSwitch namespace test is: "foo" {"moo"=>"goo"}' within 5 seconds

  Scenario: User can assign one namespace to another
    Given metadata added to "TestSwitch" in namespace "test":
      """
      {
      "value": "foo",
      "config": { "bar": 'baz' }
      }
      """
    And metadata added to "TestSwitch2" in namespace "second":
      """
      {
      "value": "boo",
      "config": { "moo": 'goo' }
      }
      """
    And code in a rules file:
      """
      TestSwitch.meta['test'] = TestSwitch2.meta['second']
      logger.info("TestSwitch namespace test is: \"#{TestSwitch.meta['test']&.value}\" #{TestSwitch.meta['test']}")
      TestSwitch.meta['test'].value = 'baa' # make sure this doesn't alter TestSwitch2's metadata
      logger.info("TestSwitch namespace test is: \"#{TestSwitch.meta['test']&.value}\" #{TestSwitch.meta['test']}")
      logger.info("TestSwitch2 namespace second is: \"#{TestSwitch2.meta['second']&.value}\" #{TestSwitch2.meta['second']}")
      """
    When I deploy the rules file
    Then It should log 'TestSwitch namespace test is: "boo" {"moo"=>"goo"}' within 5 seconds
    And It should log 'TestSwitch namespace test is: "baa" {"moo"=>"goo"}' within 5 seconds
    And It should log 'TestSwitch2 namespace second is: "boo" {"moo"=>"goo"}' within 5 seconds
