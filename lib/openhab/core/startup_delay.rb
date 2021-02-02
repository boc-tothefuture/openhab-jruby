# frozen_string_literal: true

require 'core/log'

#
# Module when included will pause the current thread until OpenHAB is ready for interaction
#
module StartupDelay
  include Logging

  CHECK_DELAY = 10
  private_constant :CHECK_DELAY

  logger.info('Checking for Automation manager')
  # rubocop: disable Style/GlobalVars
  until $scriptExtension.get('automationManager')
    logger.info("Automation manager not loaded, checking again in #{CHECK_DELAY} seconds.")
    sleep CHECK_DELAY
  end
  # rubocop: enable Style/GlobalVars
  logger.info 'Automation manager check complete.'
end
