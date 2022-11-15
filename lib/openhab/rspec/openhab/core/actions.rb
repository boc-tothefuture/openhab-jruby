# frozen_string_literal: true

module OpenHAB
  module Core
    module Actions
      # rubocop:disable Lint/UnusedMethodArgument
      # redefine these to do nothing so that rules won't fail

      module_function

      def notify(msg, email: nil)
        logger.debug("notify: #{msg}")
      end

      def say(text, voice: nil, sink: nil, volume: nil)
        logger.debug("say: #{text}")
      end

      def play_sound(filename, sink: nil, volume: nil)
        logger.debug("play_sound: #{filename}")
      end

      # rubocop:enable Lint/UnusedMethodArgument
    end
  end
end
