# frozen_string_literal: true

module OpenHAB
  module Core
    #
    # Access to global actions.
    #
    # All OpenHAB's actions including those provided by add-ons are available, notably:
    # * Audio
    # * Voice
    # * Things
    # * Ephemeris
    # * Exec
    # * HTTP
    # * Ping
    #
    # From add-ons, e.g.:
    # * Transformation
    # * PersistenceExtensions (see {Items::Persistence})
    # * NotificationAction (from [OpenHAB Cloud Connector](https://www.openhab.org/addons/integrations/openhabcloud/))
    #
    # Global actions are available as "global" methods on {OpenHAB::DSL}, or
    # explicitly from this {Actions} module, or you can explicitly reference a
    # specific action.
    #
    # Thing-specific actions can be accessed from the {Things::Thing Thing} object.
    # See {Things::Thing#actions Thing#actions}.
    #
    # @example Run the TTS engine and output to the default audio sink. For more information see [Voice](https://www.openhab.org/docs/configuration/multimedia.html#voice)
    #   rule 'Say the time every hour' do
    #     every :hour
    #     run { say "The time is #{TimeOfDay.now}" }
    #   end
    #
    #   rule 'Play an audio file' do
    #     every :hour
    #     run { play_sound "beep.mp3", volume: 100 }
    #   end
    #
    #   play_stream 'example.com'
    #
    # @example Send a broadcast notification via the OpenHAB Cloud
    #   rule 'Send an alert' do
    #     changed Alarm_Triggered, to: ON
    #     run { notify 'Red Alert!' }
    #   end
    #
    # @example Execute an external command
    #   rule 'Run a command' do
    #     every :day
    #     run do
    #       execute_command_line('/bin/true')
    #     end
    #   end
    #
    # @example Execute an external command, referencing the Exec module directly
    #   rule 'Run a command' do
    #     every :day
    #     run do
    #       OpenHAB::Core::Actions::Exec::execute_command_line('/bin/true')
    #     end
    #   end
    #
    # @example Run a transformation
    #   transform("MAP", "myfan.map", "0")
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
          raise NoMethodError, "NotificationAction is not available. Please install the OpenHAB cloud addon"
        end

        if email
          NotificationAction.send_notification(email.to_s, msg.to_s, icon&.to_s, severity&.to_s)
        else
          NotificationAction.send_broadcast_notification(msg.to_s, icon&.to_s, severity&.to_s)
        end
      end

      #
      # Say text via OpenHAB Text-To-Speech service, Voice.say()
      #
      # @param text [String] The text to say
      # @param voice [String] Specify a particular voice to use
      # @param sink [String] Specify a particular sink to output the speech
      # @param volume [PercentType] Specify the volume for the speech
      #
      # @return [void]
      #
      def say(text, voice: nil, sink: nil, volume: nil)
        volume = PercentType.new(volume) unless volume.is_a?(PercentType) || volume.nil?
        Voice.say(text.to_s, voice&.to_s, sink&.to_s, volume)
      end

      #
      # Play an audio file via OpenHAB sound service, Audio.playSound()
      #
      # @param filename [String] The sound file to play
      # @param sink [String] Specify a particular sink to output the speech
      # @param volume [PercentType] Specify the volume for the speech
      #
      # @return [void]
      #
      def play_sound(filename, sink: nil, volume: nil)
        volume = PercentType.new(volume) unless volume.is_a?(PercentType) || volume.nil?
        Audio.play_sound(sink&.to_s, filename.to_s, volume)
      end

      #
      # Play an audio stream from an URL to the given sink(s). Set url to nil if streaming should be stopped
      #
      # @param [String] url The URL of the audio stream
      # @param [String] sink The audio sink, or nil to use the default audio sink
      #
      # @return [void]
      #
      def play_stream(url, sink: nil)
        Audio.play_stream(sink&.to_s, url)
      end

      #
      # Delegate missing methods to any available global actions.
      #
      def method_missing(method, *args, &block)
        Actions.constants.each do |constant|
          mod = Actions.const_get(constant)
          return mod.public_send(method, *args, &block) if mod.respond_to?(method)
        end

        super
      end

      # @!visibility private
      def respond_to_missing?(method_name, _include_private = false)
        Actions.constants.each do |constant|
          mod = Actions.const_get(constant)
          return true if mod.respond_to?(method_name)
        end

        super
      end
    end
  end
end
