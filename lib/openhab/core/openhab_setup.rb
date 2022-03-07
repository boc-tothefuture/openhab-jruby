# frozen_string_literal: true

require 'openhab/log/logger'
require 'openhab/core/services'

module OpenHAB
  #
  # Core support for OpenHAB JRuby Library
  #
  module Core
    include OpenHAB::Log

    # @return [Integer] Number of seconds to wait between checks for automation manager
    CHECK_DELAY = 10
    private_constant :CHECK_DELAY

    #
    # Wait until OpenHAB engine ready to process
    #
    def self.wait_till_openhab_ready
      logger.trace('Checking readiness of OpenHAB')
      until OpenHAB::Core.automation_manager
        logger.trace("Automation manager not loaded, checking again in #{CHECK_DELAY} seconds.")
        sleep CHECK_DELAY
      end
      logger.trace 'Automation manager instantiated, OpenHAB ready for rule processing.'
    end
  end
end
