Feature: persistence
  Rule languages support Openhab Persistence

  Background:
    Given Clean OpenHAB with latest Ruby Libraries
    And feature 'openhab-persistence-mapdb' installed
    And groups:
      | name       | type   | function |
      | Test_Group | Number | MIN      |

    And items:
      | type   | name    | groups     |
      | Number | Number1 | Test_Group |
      | Number | Number2 | Test_Group |

  Scenario: Check that PersistenceExtensions is available
    Given code in a rules file:
      """
      logger.info("Persistence is defined: #{defined? PersistenceExtensions}")
      """
    When I deploy the rule
    Then It should log 'Persistence is defined: constant' within 5 seconds

  Scenario: Make calls to various Persistence methods
    Given code in a rules file:
      """
      java_import java.time.ZonedDateTime
      @@last_update = nil

      rule 'record updated time' do
        updated Number1
        triggered do |item|
          @@last_update = ZonedDateTime.now
          logger.info("#{item.name} = #{item.state} at: #{TimeOfDay.now}")
        end
      end

      rule 'update' do
        on_start
        run do
          Number1.update 10
          sleep 1
          persistence(:mapdb) do
            Number1.persist
            Test_Group.persist
            logger.info("Last update: #{Number1.last_update}")
            logger.info("Last update: #{Test_Group.last_update}")
            %w[
            average_since
            changed_since
            delta_since
            deviation_since
            evolution_rate
            historic_state
            maximum_since
            minimum_since
            sum_since
            updated_since
            variance_since
            ].each do |method|
              logger.info("#{method}: #{Number1.send(method, 1.minute)}")
              logger.info("#{method}: #{Number1.send(method, ZonedDateTime.now.minusMinutes(1))}")
              logger.info("#{method}: #{Test_Group.send(method, 1.minute)}")
              logger.info("#{method}: #{Test_Group.send(method, ZonedDateTime.now.minusMinutes(1))}")
            end
            logger.info("Persistence checks done")
          end
        end
      end
      """
    When I deploy the rule
    Then It should log 'Persistence checks done' within 5 seconds

  Scenario: Persistence data with Units of Measurement
    Given groups:
      | type         | name      | label     | pattern | function |
      | Number:Power | Max_Power | Max Power | %.1f kW | MAX      |

    And items:
      | type         | name         | label | pattern | state | groups    |
      | Number:Power | Number_Power | Power | %.1f kW | 0 kW  | Max_Power |

    And code in a rules file:
      """
      rule 'update persistence' do
        on_start
        run { Number_Power.update "3 kW" }
        delay 3.second
        run do
          logger.info("Average: #{Number_Power.average_since(10.seconds, :mapdb)}")
          logger.info("Average Max: #{Max_Power.average_since(10.seconds, :mapdb)}")
        end
      end
      """
    When I deploy the rule
    Then It should log 'Average: 3 kW' within 10 seconds
    And It should log 'Average Max: 3 kW' within 10 seconds

  Scenario Outline: Persistence supports various types of timestamp
    Given code in a rules file:
      """
      logger.info("Updated since <since>: #{Number1.updated_since(<since>, :mapdb)}")
      """
    When I deploy the rule
    Then It should log "Updated since <since>: " within 5 seconds
    Examples:
      | since                           |
      | ZonedDateTime.now.minusHours(1) |
      | MIDNIGHT                        |
      | NOON                            |
      | '6am'                           |
      | 1.hour                          |