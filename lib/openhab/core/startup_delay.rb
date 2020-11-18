# frozen_string_literal: true

require 'core/log'

module StartupDelay
  include Logging

  CHECK_DELAY = 10
  logger.info('Checking for Automation manager')
  until $scriptExtension.get('automationManager')
    logger.info("Automation manager not loaded, checking again in #{CHECK_DELAY} seconds.")
    sleep CHECK_DELAY
  end
  logger.info 'Automation manager check complete.'
end
