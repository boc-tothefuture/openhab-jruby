# frozen_string_literal: true

require 'core/dsl/property'
require 'core/log'

module Guard
  include DSLProperty

  prop_array :only_if
  prop_array :not_if

  class Guard
    include Logging

    def initialize(only_if: nil, not_if: nil)
      @only_if = only_if
      @not_if = not_if
    end

    def to_s
      "only_if: #{@only_if}, not_if: #{@not_if}"
    end

    def should_run?
      logger.trace("Checking guards #{self}")
      check(@only_if, check_type: :only_if) && check(@not_if, check_type: :not_if)
    end

    private

    def check(conditions, check_type:)
      return true if conditions.nil? || conditions.empty?

      procs, items = conditions.flatten.partition { |condition| condition.is_a? Proc }
      logger.trace("Procs: #{procs} Items: #{items}")

      items.each { |item| logger.trace("#{item} active? #{item.active?}") }

      case check_type
      when :only_if
        items.all?(&:active?) && procs.all?(&:call)
      when :not_if
        items.none?(&:active?) && procs.none?(&:call)
      else
        raise "Unexpected check type: #{check_type}"
      end
    end
  end
end
