# frozen_string_literal: true

module OpenHAB
  # Supports Logging
  module Log
    # This module holds global configuration values
    module Configuration
      # -*- coding: utf-8 -*-
      LOG_PREFIX = 'org.openhab.automation.jruby'

      #
      # Gets the log prefix
      #
      # @return [String] Prefix for all log entries
      #
      def self.log_prefix
        LOG_PREFIX
      end
    end
  end
end
