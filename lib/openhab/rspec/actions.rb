# frozen_string_literal: true

module OpenHAB
  module DSL
    module Actions
      # redefine these to do nothing so that rules won't fail
      def notify(msg, email: nil) # rubocop:disable Lint/UnusedMethodArgument:
        logger.debug("notify: #{msg}")
      end

      def say(text, voice: nil, sink: nil, volume: nil) # rubocop:disable Lint/UnusedMethodArgument:
        logger.debug("say: #{text}")
      end

      def play_sound(filename, sink: nil, volume: nil) # rubocop:disable Lint/UnusedMethodArgument:
        logger.debug("play_sound: #{filename}")
      end
    end
  end
end
