# frozen_string_literal: true

require 'core/dsl/property'
require 'core/log'

module OpenHAB
  module Core
    module DSL
      module Rule
        module Guard
          include DSLProperty

          prop_array(:only_if) do |item|
            unless item.is_a?(Proc) || item.respond_to?(:truthy?)
              raise "Object passed to only_if must respond_to 'truthy?'"
            end
          end

          prop_array(:not_if) do |item|
            unless item.is_a?(Proc) || item.respond_to?(:truthy?)
              raise "Object passed to not_if must respond_to 'truthy?'"
            end
          end

          class Guard
            include Logging

            def initialize(only_if: nil, not_if: nil)
              @only_if = only_if
              @not_if = not_if
            end

            def to_s
              "only_if: #{@only_if}, not_if: #{@not_if}"
            end

            def should_run?(event)
              logger.trace("Checking guards #{self}")
              check(@only_if, check_type: :only_if, event: event) && check(@not_if, check_type: :not_if, event: event)
            end

            private

            def check(conditions, check_type:, event:)
              return true if conditions.nil? || conditions.empty?

              procs, items = conditions.flatten.partition { |condition| condition.is_a? Proc }
              logger.trace("Procs: #{procs} Items: #{items}")

              items.each { |item| logger.trace("#{item} truthy? #{item.truthy?}") }

              case check_type
              when :only_if
                items.all?(&:truthy?) && procs.all? { |proc| proc.call(event) }
              when :not_if
                items.none?(&:truthy?) && procs.none? { |proc| proc.call(event) }
              else
                raise "Unexpected check type: #{check_type}"
              end
            end
          end
        end
      end
    end
  end
end
