Feature:  attachments
  Rule languages supports attachements on triggers

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

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
      | every :second                                              | qux        | I wait 2 seconds                                          |
      | cron five_seconds_from_now                                 | qab        | I wait 5 seconds                                          |
