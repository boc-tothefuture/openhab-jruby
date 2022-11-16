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

  Scenario: Make calls to various Persistence methods
    Given code in a rules file:
      """
      @last_update = nil

      rule 'record updated time' do
        updated Number1
        triggered do |item|
          @last_update = ZonedDateTime.now
          logger.info("#{item.name} = #{item.state} at: #{@last_update}")
        end
      end

      rule 'update' do
        on_start
        run do
          Number1.update 10
          sleep 1
          persistence(:rrd4j) do
            Number1.persist
            Test_Group.persist
            logger.info("Last update: #{Number1.last_update}")
            logger.info("Last update: #{Test_Group.last_update}")
            %i[
            average_since
            changed_since?
            delta_since
            deviation_since
            evolution_rate
            historic_state
            maximum_since
            minimum_since
            sum_since
            updated_since?
            variance_since
            ].each do |method|
              logger.info("#{method}: #{Number1.__send__(method, 1.minute.ago)}")
              logger.info("#{method}: #{Test_Group.__send__(method, 1.minute.ago)}")
            end

            %i[
              average_between
              changed_between?
              delta_between
              deviation_between
              maximum_between
              minimum_between
              sum_between
              updated_between?
              variance_between
            ].each do |method|
              logger.info("#{method}: #{Number1.__send__(method, 2.minute.ago, 1.minute.ago)}")
              logger.info("#{method}: #{Test_Group.__send__(method, 2.minute.ago, 1.minute.ago)}")
            end if OpenHAB::Core::Actions::PersistenceExtensions.methods.include? :average_between
            logger.info("Persistence checks done")
          end
        end
      end
      """
    When I deploy the rule
    Then It should log 'Persistence checks done' within 10 seconds

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
        run { Number_Power.update 3 | "kW" }
        delay 3.second
        run do
          logger.info("Average: #{Number_Power.average_since(10.seconds.ago, :mapdb)}")
          logger.info("Average Max: #{Max_Power.average_since(10.seconds.ago, :mapdb)}")
        end
      end
      """
    When I deploy the rule
    Then It should log 'Average: 3 kW' within 10 seconds
    And It should log 'Average Max: 3 kW' within 10 seconds

  Scenario: Persistence data on plain Number Item
    Given groups:
      | type   | name      | label     | function |
      | Number | Max_Power | Max Power | MAX      |

    And items:
      | type   | name         | label | state | groups    |
      | Number | Number_Power | Power | 0     | Max_Power |

    And code in a rules file:
      """
      rule 'update persistence' do
        on_start
        run { Number_Power.update 3 }
        delay 3.second
        run do
          logger.info("Average: #{Number_Power.average_since(10.seconds.ago, :mapdb)}")
          logger.info("Average Max: #{Max_Power.average_since(10.seconds.ago, :mapdb)}")
        end
      end
      """
    When I deploy the rule
    Then It should log 'Average: 3' within 10 seconds
    And It should log 'Average Max: 3' within 10 seconds

  Scenario: Persistence support various time arguments
    Given items:
      | type   | name         | label | state |
      | Number | Number_Power | Power | 10    |

    And code in a rules file:
      """
      rule 'update persistence' do
        on_start
        run { Number_Power.update 3 }
        delay 5.second
        run do
          logger.info("Max: #{Number_Power.maximum_since(<time>, :mapdb)}")
        end
      end
      """
    When I deploy the rule
    Then It should log 'Max: 3' within 10 seconds
    Examples:
      | time          |
      | 3.seconds.ago |
      | Time.now - 3  |

  Scenario: Check that HistoricState directly returns a state
    Given items:
      | type         | name         | label | pattern | state |
      | Number:Power | Number_Power | Power | %.1f kW | 0 kW  |

    And code in a rules file:
      """
      rule 'Check HistoricState' do
        on_start
        run { Number_Power.update 3 | "kW" }
        delay 3.second
        run do
          max = Number_Power.maximum_since(10.seconds.ago, :mapdb)
          logger.info("Max time: #{max.timestamp}") # If this caused an error, the next line won't execute
          logger.info("Max: #{max}") if max == max.state
        end
      end
      """
    When I deploy the rule
    Then It should log 'Max: 3 kW' within 10 seconds
