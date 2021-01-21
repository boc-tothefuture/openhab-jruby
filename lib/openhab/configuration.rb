# frozen_string_literal: true

# This module holds global configuration values
module Configuration
  # -*- coding: utf-8 -*-
  LOG_PREFIX = 'jsr223.jruby'

  #
  # Gets the log prefix
  #
  # @return [String] Prefix for all log entries
  #
  def self.log_prefix
    LOG_PREFIX
  end
end
