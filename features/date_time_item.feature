Feature: date_time_item
  Rule language supports DateTime Items

    Background:
    Given Clean OpenHAB with latest Ruby Libraries
    And group "Dates"
    And items:
      | type     | name      | label      | group | state                     |
      | DateTime | DateOne   | Date One   | Dates | 1970-01-01T00:00:00+00:00 |
      | DateTime | DateTwo   | Date Two   | Dates | 2021-01-31T08:00:00+00:00 |
      | DateTime | DateThree | Date Three | Dates | 2021-01-31T14:00:00+06:00 |

    Scenario Outline: DateTime Items support math operations
      Given item "DateOne" state is changed to "<initial>"
      And code in a rules file
        """
        DateOne << DateOne<operator> <operand>
        """
      When I deploy the rules file
      Then "DateOne" should be in state "<final>" within 5 seconds
      Examples:
        | initial                  | operator | operand    | final                        |
        | 1970-01-31T08:00:00+0200 | +        | 600        | 1970-01-31T08:10:00.000+0200 |
        | 1970-01-31T08:00:00+0000 | -        | 600        | 1970-01-31T07:50:00.000+0000 |
        | 1970-01-31T08:00:00+0000 | +        | '00:05'    | 1970-01-31T08:05:00.000+0000 |
        | 1970-01-31T08:00:00+0200 | -        | '00:05'    | 1970-01-31T07:55:00.000+0200 |
        | 1970-01-31T08:00:00+0000 | +        | 20.minutes | 1970-01-31T08:20:00.000+0000 |
        | 1970-01-31T08:00:00+0000 | -        | 20.minutes | 1970-01-31T07:40:00.000+0000 |

    Scenario Outline: Ruby Time methods work
      Given code in a rules file      
        """
        logger.info(DateTwo.<method>)
        """
      When I deploy the rules file
      Then It should log "<result>" within 5 seconds
      Examples:
        | method  | result |
        | sunday? | true   |
        | monday? | false  |
        | wday    | 0      |
        | utc?    | true   |
        | month   | 1      |
        | zone    | Z      |

    Scenario: Items with same time but different zone should be equal
      Given code in a rules file
        """
        if DateTwo == DateThree
          logger.info("Same date")
        end
        """
      When I deploy the rules file
      Then It should log "Same date" within 5 seconds

    Scenario: Items can be updated by ruby Time objects
      Given code in a rules file
        """
        DateOne << Time.at(60 * 60 * 24).utc
        """
      When I deploy the rules file
      Then "DateOne" should be in state "1970-01-02T00:00:00.000+0000" within 5 seconds

    Scenario Outline: Calculating time differences work
      Given item "DateOne" state is changed to "2021-01-31T09:00:00+00:00"
      And code in a rules file
        """
        logger.info((DateOne - <operand>).to_i)
        """
      When I deploy the rules file
      Then It should log "<result>" within 5 seconds
      Examples:
        | operand                     | result |
        | '2021-01-31T07:00:00+00:00' | 7200   |
        | Time.utc(2021, 1, 31, 7)    | 7200   |
        | DateTwo                     | 3600   |

    Scenario: DateTimeItems work with TimeOfDay ranges
      Given code in a rules file
        """
        case DateThree
        when between('00:00'...'08:00')
          logger.info('DateThree is between 00:00..08:00')
        when between('08:00'...'16:00')
          logger.info('DateThree is between 08:00..16:00')
        when between('16:00'..'23:59')
          logger.info('DateThree is between 16:00...23:59')
        end
        """
      When I deploy the rules file
      Then It should log "DateThree is between 08:00..16:00" within 5 seconds

    Scenario: between-ranges can be created from DateTimeItems
      Given code in a rules file
        """
        if between(DateOne...DateTwo).cover? '05:00'
          logger.info('05:00 is between DateOne..DateTwo')
        end
        """
      When I deploy the rules file
      Then It should log "05:00 is between DateOne..DateTwo" within 5 seconds
