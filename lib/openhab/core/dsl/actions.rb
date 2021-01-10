# frozen_string_literal: true

require 'java'
require 'openhab/osgi'

module OpenHAB
  module Core
    module DSL
      #
      # Module to import and steramlime access to OpenHAB actions
      #
      module Actions
        java_import org.openhab.core.library.types.PercentType
        include Logging

        NotificationAction = nil # Avoid the (NameError) uninitialized constant error
        OpenHAB::OSGI.services('org.openhab.core.model.script.engine.action.ActionService')&.each do |service|
          java_import service.actionClass.to_s
          logger.info("Loaded ACTION: #{service.actionClass}")
        end
        java_import org.openhab.core.model.script.actions.Exec
        java_import org.openhab.core.model.script.actions.HTTP
        java_import org.openhab.core.model.script.actions.Ping

        #
        # Return an OpenHAB Action object for the given scope and thing
        #
        # @param scope [String] The action scope
        # @param thing_uid [String] Thing UID
        #
        # @return [Object] OpenHAB action
        #
        def action(scope, thing_uid)
          $actions.get(scope, thing_uid)
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
          unless NotificationAction
            raise NoMethodError, 'NotificationAction is not available. Please install the OpenHAB cloud addon'
          end

          if email
            NotificationAction&.sendNotification email, msg
          else
            NotificationAction&.sendBroadcastNotification msg
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
          volume = PercentType.new(volume&.to_i) unless volume&.is_a? PercentType || volume.nil?
          Voice.say text, voice, sink, volume
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
          volume = PercentType.new(volume&.to_i) unless volume&.is_a? PercentType || volume.nil?
          Audio.playSound sink, filename, volume
        end
      end
    end
  end
end
