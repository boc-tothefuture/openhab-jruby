Feature:  attachments
  Rule languages supports attachements on triggers

  Background:
    Given Clean OpenHAB with latest Ruby Libraries
    And items:
      | type   | name    | label             | state |
      | Switch | Switch1 | Switch Number One | OFF   |

  @conf_files
  Scenario Outline: Triggers works with attachments
    Given a deployed rule:
      """
       def five_seconds_from_now
         cron = (Time.now + 5).strftime('%S %M %H ? * ?').tap { |cron| logger.info(cron)}
       end

      rule 'Access attachment' do
        <trigger>, attach: '<attachment>'
        run { |event| logger.info("attachment - #{event.attachment}")}
      end
      """
    When <action>
    Then It should log 'attachment - <attachment>' within 15 seconds
    Examples: Checks multiple attachments
      | trigger                                                    | attachment | action                                                    |
      | changed Switch1                                            | foo        | item "Switch1" state is changed to "ON"                   |
      | received_command Switch1                                   | baz        | item "Switch1" state is changed to "ON"                   |
      | updated Switch1                                            | bar        | item "Switch1" state is changed to "ON"                   |
      | trigger 'core.ItemStateUpdateTrigger', itemName: 'Switch1' | moo        | item "Switch1" state is changed to "ON"                   |
      | channel 'astro:sun:home:rise#event'                        | quz        | channel "astro:sun:home:rise#event " is triggered         |
      | on_start true                                              | qaz        | I wait 2 seconds                                          |
      | every :second                                              | qux        | I wait 2 seconds                                          |
      | cron five_seconds_from_now                                 | qab        | I wait 5 seconds                                          |
      | watch OpenHAB.conf_root/'foo'                              | qac        | I create a file in subdirectory 'foo' of conf named 'bar' |


  Scenario Outline: Guards have access to attachments
    Given a deployed rule:
      """
       def five_seconds_from_now
         cron = (Time.now + 5).strftime('%S %M %H ? * ?').tap { |cron| logger.info(cron)}
       end

      rule 'Access attachment' do
        <trigger>, attach: '<attachment>'
        only_if { |event| logger.info("attachment - #{event.attachment}") }
        only_if { false } # the run block doesn't need to execute
        run { logger.info(Switch1) }
      end
      """
    When <action>
    Then It should log 'attachment - <attachment>' within 5 seconds
    Examples: Checks multiple attachments
      | trigger                                                    | attachment | action                                            |
      | changed Switch1                                            | foo        | item "Switch1" state is changed to "ON"           |
      | received_command Switch1                                   | baz        | item "Switch1" state is changed to "ON"           |
      | updated Switch1                                            | bar        | item "Switch1" state is changed to "ON"           |
      | trigger 'core.ItemStateUpdateTrigger', itemName: 'Switch1' | moo        | item "Switch1" state is changed to "ON"           |
      | channel 'astro:sun:home:rise#event'                        | quz        | channel "astro:sun:home:rise#event " is triggered |
      | on_start true                                              | qaz        | I wait 2 seconds                                  |
      | every :second                                              | qux        | I wait 2 seconds                                  |
      | cron five_seconds_from_now                                 | qab        | I wait 5 seconds                                  |
