Feature:  channels
  Rule languages supports channels

  Background:
    Given Clean OpenHAB with latest Ruby Libraries
    And feature 'openhab-binding-astro' installed
    And things:
      | id   | thing_uid | label          | config                | status |
      | home | astro:sun | Astro Sun Data | {"geolocation":"0,0"} | enable |

  Scenario Outline: Rule supports channel triggers
    Given a deployed rule:
      """
      rule 'Execute rule when channel is triggered' do
        <trigger>
        run { logger.info("Channel triggered") }
      end
      """
    When channel "<channel>" is triggered
    Then It should log 'Channel triggered' within 5 seconds
    Examples: Checks support for string based and thing based channels
      | trigger                                                       | channel                   |
      | channel 'astro:sun:home:rise#event'                           | astro:sun:home:rise#event |
      | channel 'rise#event', thing: 'astro:sun:home'                 | astro:sun:home:rise#event |
      | channel 'rise#event', thing: things['astro:sun:home']         | astro:sun:home:rise#event |
      | channel 'rise#event', thing: things['astro:sun:home'].uid     | astro:sun:home:rise#event |
      | channel 'rise#event', thing: [things['astro:sun:home']]       | astro:sun:home:rise#event |
      | channel 'rise#event', thing: [things['astro:sun:home'].uid]   | astro:sun:home:rise#event |
      | channel things['astro:sun:home'].channels['rise#event']       | astro:sun:home:rise#event |
      | channel things['astro:sun:home'].channels['rise#event'].uid   | astro:sun:home:rise#event |
      | channel [things['astro:sun:home'].channels['rise#event']]     | astro:sun:home:rise#event |
      | channel [things['astro:sun:home'].channels['rise#event'].uid] | astro:sun:home:rise#event |


  Scenario: Rule provides access channel trigger events in run block
    Given a deployed rule:
      """
      rule 'Rule provides access to channel trigger events in run block' do
        channel 'astro:sun:home:rise#event', triggered: 'START'
        run { |trigger| logger.info("Channel(#{trigger.channel}) triggered event: #{trigger.event}") }
      end
      """
    When channel "astro:sun:home:rise#event" is triggered with "START"
    Then It should log 'Channel(astro:sun:home:rise#event) triggered event: START' within 5 seconds

  Scenario Outline: Rule supports multiple channels
    Given a deployed rule:
      """
      rule 'Rules support multiple channels' do
        <trigger>
        run { logger.info("Channel triggered") }
      end
      """
    When channel "<channel>" is triggered
    Then It should log 'Channel triggered' within 5 seconds
    Examples: Checks arrays of channels
      | trigger                                                     | channel                   |
      | channel ['rise#event','set#event'], thing: 'astro:sun:home' | astro:sun:home:rise#event |
      | channel ['rise#event','set#event'], thing: 'astro:sun:home' | astro:sun:home:set#event  |

  Scenario Outline: Rule supports multiple channels and triggers
    Given a deployed rule:
      """
      rule 'Rules support multiple channels and triggers' do
        <trigger>
        run { logger.info("Channel triggered") }
      end
      """
    When channel "<channel>" is triggered with "<event>"
    Then It should log 'Channel triggered' within 5 seconds
    Examples: Checks arrays of chanels and arrays of triggers
      | trigger                                                                                   | channel                   | event |
      | channel ['rise#event','set#event'], thing: 'astro:sun:home', triggered: ['START', 'STOP'] | astro:sun:home:rise#event | START |
      | channel ['rise#event','set#event'], thing: 'astro:sun:home', triggered: ['START', 'STOP'] | astro:sun:home:set#event  | START |
      | channel ['rise#event','set#event'], thing: 'astro:sun:home', triggered: ['START', 'STOP'] | astro:sun:home:rise#event | STOP  |
      | channel ['rise#event','set#event'], thing: 'astro:sun:home', triggered: ['START', 'STOP'] | astro:sun:home:set#event  | STOP  |
