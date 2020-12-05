# frozen_string_literal: true

module OpenHAB
  module Core
    module Cron
      def cron_expression_hash
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
