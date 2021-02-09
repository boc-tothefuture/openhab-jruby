Feature: persistence
  Rule languages support Openhab Persistence

  Background:
    Given Clean OpenHAB with latest Ruby Libraries
    And feature 'openhab-persistence-rrd4j' installed
    And items:
      | type   | name    |
      | Number | Number1 |
      | Number | Number2 |

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
          persistence(:rrd4j) do
            Number1.persist
            logger.info("Last update: #{Number1.last_update}")
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
            end
            logger.info("Persistence checks done")
          end
        end
      end
      """
    When I deploy the rule
    Then It should log 'Persistence checks done' within 5 seconds