# frozen_string_literal: true

module OpenHAB
  module Core
    #
    # Access to global actions.
    #
    # All openHAB's actions including those provided by add-ons are available, notably:
    # * Audio
    # * Ephemeris
    # * Exec
    # * HTTP
    # * Ping
    # * Semantics (see {Items::Semantics})
    # * Voice
    #
    # From add-ons, e.g.:
    # * NotificationAction (from
    #   [openHAB Cloud Connector](https://www.openhab.org/addons/integrations/openhabcloud/);
    #   see {notify notify})
    # * PersistenceExtensions (see {Items::Persistence})
    # * Transformation
    #
    # Thing-specific actions can be accessed from the {Things::Thing Thing} object.
    # See {Things::Thing#actions Thing#actions}.
    #
    # @example Run the TTS engine and output to the default audio sink. For more information see [Voice](https://www.openhab.org/docs/configuration/multimedia.html#voice)
    #   rule 'Say the time every hour' do
    #     every :hour
    #     run { Voice.say "The time is #{TimeOfDay.now}" }
    #   end
    #
    #   rule 'Play an audio file' do
    #     every :hour
    #     run { Audio.play_sound "beep.mp3", volume: 100 }
    #   end
    #
    #   Audio.play_stream 'example.com'
    #
    # @example Send a broadcast notification via the openHAB Cloud
    #   rule 'Send an alert' do
    #     changed Alarm_Triggered, to: ON
    #     run { notify 'Red Alert!' }
    #   end
    #
    # @example Execute an external command
    #   rule 'Run a command' do
    #     every :day
    #     run do
    #       Exec.execute_command_line('/bin/true')
    #     end
    #   end
    #
    # @example Run a transformation
    #   Transformation.transform("MAP", "myfan.map", "0")
    #
    module Actions
      OSGi.services("org.openhab.core.model.script.engine.action.ActionService")&.each do |service|
        action_class = service.action_class
        module_name = action_class.simple_name
        action = if action_class.interface?
                   impl = OSGi.service(action_class)
                   unless impl
                     logger.error("Unable to find an implementation object for action service #{action_class}.")
                     next
                   end
                   const_set(module_name, impl)
                 else
                   (java_import action_class.ruby_class).first
                 end
        logger.trace("Loaded ACTION: #{action_class}")
        Object.const_set(module_name, action)
      end

      # Import common actions
      %w[Exec HTTP Ping].each do |action|
        klass = (java_import "org.openhab.core.model.script.actions.#{action}").first
        Object.const_set(action, klass)
      end

      module_function

      #
      # Send notification to an email or broadcast
      #
      # @param msg [String] The notification message to send
      # @param email [String, nil] The email address to send to. If nil, the message will be broadcast
      # @param icon [String, Symbol, nil]
      # @param severity [String, Symbol, nil]
      #
      # @return [void]
      #
      def notify(msg, email: nil, icon: nil, severity: nil)
        unless Actions.const_defined?(:NotificationAction)
          raise NoMethodError, "NotificationAction is not available. Please install the openHAB cloud addon"
        end

        if email
          NotificationAction.send_notification(email.to_s, msg.to_s, icon&.to_s, severity&.to_s)
        else
          NotificationAction.send_broadcast_notification(msg.to_s, icon&.to_s, severity&.to_s)
        end
      end
    end
  end
end
