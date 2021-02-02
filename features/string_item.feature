Feature:  string_item
  Rule languages supports String Items

  Background:
    Given Clean OpenHAB with latest Ruby Libraries
    And group "Strings"
    And items:
      | type   | name        | label        | group   |
      | String | StringOne   | String One   | Strings |
      | String | StringTwo   | String Two   | Strings |
      | String | StringThree | String Three | Strings |

  Scenario: StringItem supports string operations
    Given item "StringOne" state is changed to "Hello"
    And code in a rules file
      """
      StringOne << StringOne + " World!"
      """
    When I deploy the rules file
    Then "StringOne" should be in state "Hello World!" within 5 seconds

  Scenario: StringItem acts as a string for other String Operations
    Given item "StringOne" state is changed to " World!"
    And code in a rules file
      """
      StringOne << "Hello " + StringOne
      """
    When I deploy the rules file
    Then "StringOne" should be in state "Hello World!" within 5 seconds

  Scenario: StringItem should work with grep
    Given code in a rules file
      """
      # Get all StringItems
      items.grep(StringItem)
           .each { |string| logger.info("#{string.id} is a String Item") }
      """
    When I deploy the rules file
    Then It should log "String One is a String Item" within 5 seconds
    And It should log "String Two is a String Item" within 5 seconds


  Scenario: StringItem should work with grep regex
    Given item "StringOne" state is changed to "Hello"
    And item "StringTwo" state is changed to " World!"
    And code in a rules file
      """
      # Get all Strings that start with an H
      Strings.grep(/^H/)
              .each { |string| logger.info("#{string.id} starts with an H") }
      """
    When I deploy the rules file
    Then It should log "String One starts with an H" within 5 seconds
    But It should not log "String Two starts with an H" within 5 seconds

  Scenario: StringItem responds to blank?
    Given group "BlankStrings"
    And items:
      | type   | name             | label             | group        |
      | String | NullString       | Null String       | BlankStrings |
      | String | UndefString      | Undef String      | BlankStrings |
      | String | WhitespaceString | Whitespace String | BlankStrings |
      | String | HelloString      | Hello String      | BlankStrings |
    And code in a rules file
      """
      WhitespaceString << " "
      HelloString << "Hello"
      NullString.setState(NULL)
      UndefString.setState(UNDEF)
      sleep 2
      # Get all Strings that start with an H
      BlankStrings.select(&:blank?)
              .each { |string| logger.info("#{string.id} is blank") }
      """
    When I deploy the rules file
    Then It should log "Null String is blank" within 5 seconds
    And It should log "Undef String is blank" within 5 seconds
    And It should log "Whitespace String is blank" within 5 seconds
    But It should not log "hello String is blank" within 5 seconds

  Scenario: StringItem can be compared against a string
    Given item "StringOne" state is changed to "Hello"
    And code in a rules file
      """
      logger.info("StringOne == 'Hello' is #{StringOne == 'Hello'}")
      logger.info("StringOne == 'World' is #{StringOne == 'World'}")
      logger.info("StringOne != 'Hello' is #{StringOne != 'Hello'}")
      logger.info("StringOne != 'World' is #{StringOne != 'World'}")
      """
    When I deploy the rules file
    Then It should log "StringOne == 'Hello' is true" within 5 seconds
    And It should log "StringOne == 'World' is false" within 5 seconds
    And It should log "StringOne != 'Hello' is false" within 5 seconds
    And It should log "StringOne != 'World' is true" within 5 seconds

  Scenario: StringItem can be compared against another StringItem
    Given item "StringOne" state is changed to "Hello"
    And item "StringTwo" state is changed to "World"
    And item "StringThree" state is changed to "Hello"
    And code in a rules file
      """
      logger.info("StringOne == StringTwo is #{StringOne == StringTwo}")
      logger.info("StringOne != StringTwo is #{StringOne != StringTwo}")
      logger.info("StringOne == StringThree is #{StringOne == StringThree}")
      logger.info("StringOne != StringThree is #{StringOne != StringThree}")
      """
    When I deploy the rules file
    Then It should log "StringOne == StringTwo is false" within 5 seconds
    And It should log "StringOne != StringTwo is true" within 5 seconds
    And It should log "StringOne == StringThree is true" within 5 seconds
    And It should log "StringOne != StringThree is false" within 5 seconds


