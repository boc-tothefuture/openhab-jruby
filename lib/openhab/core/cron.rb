# frozen_string_literal: true

module OpenHAB
  module Core
    module Cron
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
