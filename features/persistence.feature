Feature: persistence
  Rule languages support Openhab Persistence

  Background:
    Given Clean OpenHAB with latest Ruby Libraries
    And feature 'openhab-persistence-mapdb' installed
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

  Scenario: Persistence data with Units of Measurement
    Given items:
      | type         | name         | label | pattern | state |
      | Number:Power | Number_Power | Power | %.1f kW | 0 kW  |
    And code in a rules file:
      """
      rule 'update persistence' do
        on_start
        run { Number_Power.update "3 kW" }
        delay 3.second
        run { logger.info("Average: #{Number_Power.average_since(10.seconds, :mapdb)}") }
      end
      """
    When I deploy the rule
    Then It should log 'Average: 3 kW' within 10 seconds

  Scenario: Set default persistence
    Given items:
      | type         | name         | label | pattern | state |
      | Number:Power | Number_Power | Power | %.1f kW | 2 kW  |
    And code in a rules file:
      """
      rule 'use default persistence service' do
        on_start
        run { logger.info("Without Default Average: '#{Number_Power.average_since(10.seconds)}'") }
      end

      rule 'use default persistence service' do
        on_start
        run do
          def_default_persistence :mapdb
          logger.info("With Default Average: '#{Number_Power.average_since(10.seconds)}'")
        end
      end
      """
    When I deploy the rule
    Then It should log "With Default Average: '2 kW'" within 5 seconds
    And It should log "Without Default Average: ''" within 5 seconds
