Feature:  contact_item
  Rule languages supports Contacts

  Background:
    Given Clean OpenHAB with latest Ruby Libraries
    And group "Contacts"

  Scenario Outline: can directly compare states
    Given items:
      | type    | name       | label       | group    |
      | Contact | ContactOne | Contact One | Contacts |
    And update state for item "ContactOne" to "<update>"
    And code in a rules file
      """
      # Log contact state
      Contacts.select { |c| c == <check> }.each { |contact| logger.info("Contact #{contact.id} is #{contact.state}")}
      """
    When I deploy the rules file
    Then It should log "<log_line>" within 5 seconds
    Examples:
      | update | check   | log_line              |
      | OPEN   | OPEN    | Contact One is OPEN   |
      | CLOSED | CLOSED  | Contact One is CLOSED |

  Scenario Outline: open?/closed? checks state of contact
    Given items:
      | type    | name       | label       | group    |
      | Contact | ContactOne | Contact One | Contacts |
    And update state for item "ContactOne" to "<update>"
    And code in a rules file
      """
      # Log contact state
      Contacts.select(&:<check>).each { |contact| logger.info("Contact #{contact.id} is #{contact.state}")}
      """
    When I deploy the rules file
    Then It should log "<log_line>" within 5 seconds
    Examples:
      | update | check   | log_line              |
      | OPEN   | open?   | Contact One is OPEN   |
      | CLOSED | closed? | Contact One is CLOSED |

  Scenario: Contact can be selected with grep
    Given items:
      | type    | name       | label       | group    |
      | Contact | ContactOne | Contact One | Contacts |
      | Contact | ContactTwo | Contact Two | Contacts |
    And code in a rules file
      """
      # Get all Contacts
      items.grep(Contact)
           .each { |contact| logger.info("#{contact.id} is a Contact") }
      """
    When I deploy the rules file
    Then It should log "Contact One is a Contact" within 5 seconds
    And It should log "Contact Two is a Contact" within 5 seconds

  Scenario Outline: Contact states work in grep
    Given items:
      | type    | name       | label       | group    |
      | Contact | ContactOne | Contact One | Contacts |
    And update state for item "ContactOne" to "<update>"
    And code in a rules file
      """
      # Get dimmers in specific state
      Contacts.grep(<update>)
              .each { |contact| logger.info("#{contact.id} is in #{contact.state}") }
      """
    When I deploy the rules file
    Then It should log "Contact One is in <update>" within 5 seconds
    Examples:
      | update |
      | OPEN   |
      | CLOSED |

  Scenario Outline: Contact states work in cases
    Given items:
      | type    | name        | label       | group    |
      | Contact | TestContact | Contact One | Contacts |
    And update state for item "TestContact" to "<update>"
    And code in a rules file
      """
      #Log if contact is open or closed
      case TestContact
      when (OPEN)
        logger.info("#{TestContact.id} is open")
       when (CLOSED)
        logger.info("#{TestContact.id} is closed")
      end
      """
    When I deploy the rules file
    Then It should log "Contact One is <log>" within 5 seconds
    Examples:
      | update | log    |
      | OPEN   | open   |
      | CLOSED | closed |

  Scenario: Contact to_s returns state of contact
    Given items:
      | type    | name        |
      | Contact | TestContact |
    And update state for item "TestContact" to "OPEN"
    And code in a rules file
      """
      logger.info("#{TestContact.id} state is #{TestContact}")
      """
    When I deploy the rules file
    Then It should log "TestContact state is OPEN" within 5 seconds