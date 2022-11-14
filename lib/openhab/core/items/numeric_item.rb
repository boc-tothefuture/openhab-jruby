# frozen_string_literal: true

require "forwardable"

module OpenHAB
  module Core
    module Items
      # Mixin for implementing type coercion for number-like items
      module NumericItem
        # raw numbers translate directly to DecimalType, not a string
        # @!visibility private
        def format_type(command)
          if command.is_a?(Numeric)
            return Types::QuantityType.new(command, unit) if unit

            return Types::DecimalType.new(command)
          end

          super
        end

        %i[positive? negative? zero?].each do |predicate|
          class_eval <<~RUBY, __FILE__, __LINE__ + 1
            def #{predicate}              # def positive?
              return false unless state?  #   return false unless state?
                                          #
              state.#{predicate}          #   state.positive?
            end                           # end
          RUBY
        end
      end
    end
  end
end
