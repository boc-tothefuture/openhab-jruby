Feature:  metadata_hash
  Items support accessing metadata from different files

  Background:
    Given Clean OpenHAB with latest Ruby Libraries
    And items:
      | type   | name       |
      | Switch | TestSwitch |
    And a deployed rule:
      """
      TestSwitch.meta['animalsounds'] = { 'land' => { 'cow' => 'moo'}}
      logger.info("Metadata animalsounds created for TestSwitch: #{TestSwitch.meta['animalsounds']}")
      """

  Scenario Outline: Metadata key works when assigned in the same rule
    Given code in a rules file:
      """
      TestSwitch.meta['animalsounds'] = {"land"=>{"cow"=>"moo"}}
      code = '<metadata>'
      logger.info("#{code}: #{<metadata>}")
      """
    When I deploy the rules file
    Then It should log '<metadata>: <value>' within 5 seconds
    Examples:
      | metadata                                           | value                    |
      | TestSwitch.meta["animalsounds"]                    | {"land"=>{"cow"=>"moo"}} |
      | TestSwitch.meta.dig("animalsounds", "land")        | {"cow"=>"moo"}           |
      | TestSwitch.meta.dig("animalsounds", "land", "cow") | moo                      |


  Scenario Outline: Metadata key works when not assigned in the same rule
    Given code in a rules file:
      """
      code = '<metadata>'
      logger.info("#{code}: #{<metadata>}")
      """
    When I deploy the rules file
    Then It should log '<metadata>: <value>' within 5 seconds
    Examples:
      | metadata                                           | value                    |
      | TestSwitch.meta["animalsounds"]                    | {"land"=>{"cow"=>"moo"}} |
      | TestSwitch.meta.dig("animalsounds", "land")        | {"cow"=>"moo"}           |
      | TestSwitch.meta.dig("animalsounds", "land", "cow") | moo                      |

  Scenario Outline: Comparing against a hash literal when metadata assigned in the same rule
    Given code in a rules file:
      """
      TestSwitch.meta['animalsounds'] = {"land"=>{"cow"=>"moo"}}
      logger.info("Metadata checks out") if <metadata> == <value>
      """
    When I deploy the rules file
    Then It should log 'Metadata checks out' within 5 seconds
    Examples:
      | metadata                                           | value                    |
      | TestSwitch.meta["animalsounds"]                    | {"land"=>{"cow"=>"moo"}} |
      | TestSwitch.meta.dig("animalsounds", "land")        | {"cow"=>"moo"}           |
      | TestSwitch.meta.dig("animalsounds", "land", "cow") | "moo"                    |

  Scenario Outline: Comparing against a hash literal when metadata NOT assigned in the same rule
    Given code in a rules file:
      """
      logger.info("Metadata checks out") if <metadata> == <value>
      """
    When I deploy the rules file
    Then It should log 'Metadata checks out' within 5 seconds
    Examples:
      | metadata                                           | value                    |
      | TestSwitch.meta["animalsounds"]                    | {"land"=>{"cow"=>"moo"}} |
      | TestSwitch.meta.dig("animalsounds", "land")        | {"cow"=>"moo"}           |
      | TestSwitch.meta.dig("animalsounds", "land", "cow") | "moo"                    |

  Scenario Outline: Calling to_json on metadata config
    Given a deployed rule:
      """
      TestSwitch.meta['animalsounds'] = { 'land' => <value> }
      """
    And code in a rules file:
      """
      require 'json'
      logger.info("Metadata to_json: #{TestSwitch.meta.dig("animalsounds", "land").to_json}")
      """
    When I deploy the rules file
    Then It should log 'Metadata to_json: <json>' within 5 seconds
    Examples:
      | value                             | json                            |
      | {'cow'=>'moo'}                    | {"cow":"moo"}                   |
      | [{'cow'=>'moo'},{'sheep'=>'baa'}] | [{"cow":"moo"},{"sheep":"baa"}] |