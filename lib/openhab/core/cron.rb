# frozen_string_literal: true

module OpenHAB
  module Core
    #
    # Module for Cron related methods
    #
    module Cron
      #
      # Retruns a default map for cron expressions that fires every second
      # This map is usually updated via merge by other methods to refine cron type triggers.
      #
      # @return [Map] Map with symbols for :seconds, :minute, :hour, :dom, :month, :dow configured to fire every second
      #
      def cron_expression_map
        {
          second: '*',
          minute: '*',
          hour: '*',
          dom: '?',
          month: '*',
          dow: '?'
        }
      end
    end
  end
end
