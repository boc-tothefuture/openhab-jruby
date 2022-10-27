# frozen_string_literal: true

require "openhab/core/osgi"

module OpenHAB
  module DSL
    #
    # Module to import and streamline access to OpenHAB actions
    #
    module Actions
      include OpenHAB::Log

      OpenHAB::Core::OSGi.services("org.openhab.core.model.script.engine.action.ActionService")&.each do |service|
        java_import service.actionClass.to_s
        logger.trace("Loaded ACTION: #{service.actionClass}")
      end
      # Import common actions
      %w[Exec HTTP Ping].each { |action| java_import "org.openhab.core.model.script.actions.#{action}" }

      module_function

      #
      # Return an OpenHAB Action object for the given scope and thing
      #
      # @param scope [String] The action scope
      # @param thing_uid [String] Thing UID
      #
      # @return [Object] OpenHAB action
      #
      def actions(scope, thing_uid)
        $actions.get(scope, thing_uid)
      end

      #
      # Gets the list of action objects associated with a specific ThingUID
      #
      # @param [org.openhab.core.thing.ThingUID] thing_uid to get associated actions for
      #
      # @return [Array] of action objects associated with thing_uid, may be empty
      #
      def actions_for_thing(thing_uid)
        thing_uid = thing_uid.to_s
        action_keys = $actions.action_keys
        logger.trace("Registered actions: '#{action_keys}' for thing '#{thing_uid}'")
        action_keys.map { |action_key| action_key.split("-", 2) }
                   .select { |action_pair| action_pair.last == thing_uid }
                   .map(&:first)
                   .map { |scope| actions(scope, thing_uid) }
      end

      #
      # Send notification to an email or broadcast
      #
      # @param msg [String] The notification message to send
      # @param email [String] The email address to send to. If nil, the message will be broadcasted
      #
      # @return [void]
      #
      def notify(msg, email: nil)
        unless defined? NotificationAction
          raise NoMethodError, "NotificationAction is not available. Please install the OpenHAB cloud addon"
        end

        if email
          NotificationAction.sendNotification email.to_s, msg.to_s
        else
          NotificationAction.sendBroadcastNotification msg.to_s
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
        volume = Types::PercentType.new(volume) unless volume.is_a?(Types::PercentType) || volume.nil?
        Voice.say text.to_s, voice&.to_s, sink&.to_s, volume
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
        volume = Types::PercentType.new(volume) unless volume.is_a?(Types::PercentType) || volume.nil?
        Audio.playSound sink&.to_s, filename.to_s, volume
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
        Audio.playStream sink&.to_s, url
      end
    end
  end
end
