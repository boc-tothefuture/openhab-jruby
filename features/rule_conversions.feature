Feature:  Rule Conversions from DSL and Python

  Background:
    Given Clean OpenHAB with latest Ruby Libraries

  Scenario: Turn on office heater
    Given a rule
      """
      rule 'Use supplemental heat in office' do
        changed Office_Temperature, Thermostats_Upstairs_Temp, Office_Occupied, OfficeDoor
        run { Lights_Office_Outlet << ON }, :always
        otherwise { Lights_Office_Outlet << OFF if Lights_Office_Outlet.on? }
        only_if Office_Occupied
        only_if { OfficeDoor == CLOSED }
        only_if { Thermostate_Upstairs_Heat_Set > Office_Temperature }
        only_if { (Thermostat_Upstairs_Temp - Office_Temperature) > 2) }
      end
      """
    And item "Office_Occupied" state is changed to "ON"
    Then "Lights_Office_Outlet" should be in state "ON" within 5 seconds


  Scenario: Notify TV
    Given a rule
      """
      rule 'Notify if kids turn on the TV' do
        changed HarmonyMediaRoomActivity, from: 'PowerOff'
        run { notify_all('Media Room TV Turned On') }
        between '20:30'..'6:00'
      end
      """
    Then NOT_IMPLEMENTED

  Scenario: Notify Garage Doors
    Given a rule
      """
      def check_garage_doors(reason)
        open_doors = GarageDoors.select(&:open?)
        logger.warn("#{open_doors.length} Garge Doors are open") if open_doors.length.positive?
        open_doors.each do |door|
          "#{reason} and {door} is open".tap do |message|
            logger.warn("Sending Notification #{message}")
            notify(user: broconne@gmail.com, msg: message)
          end
        end
      end

      rule 'check garage doors at night'
        every :day, at: '20:00'
        run { check_garage_doors("It's 8PM")
      end

      rule 'check garage doors when in night mode'
        changed Alarm_Mode, to: [10,14]
        run { check_garage_doors("Alarm night mode set")
      end



      """
    Then NOT_IMPLEMENTED

  Scenario: Get Lock States
    Given a rule
      """
        rule 'Alexa Voice Command' do
          updated AlexaVoiceCommands
          triggered do |item|
            logger.warn("LastVoiceCommand received [#{item}]")


          end

        end
      """
    Then NOT_IMPLEMENTED




