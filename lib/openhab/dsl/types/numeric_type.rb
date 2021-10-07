# frozen_string_literal: true

require 'bigdecimal'
require 'forwardable'

module OpenHAB
  module DSL
    module Types
      # Mixin for methods common to DecimalType and QuantityType
      module NumericType
        # apply meta-programming to including class
        def self.included(klass)
          klass.extend Forwardable

          klass.delegate %i[to_d zero?] => :to_big_decimal
          klass.delegate %i[positive? negative? to_f to_i to_int hash] => :to_d
          # remove the JRuby default == so that we can inherit the Ruby method
          klass.remove_method :==
        end

        #
        # Check equality without type conversion
        #
        # @return [Boolean] if the same value is represented, without type
        #   conversion
        def eql?(other)
          return false unless other.instance_of?(self.class)

          compare_to(other).zero?
        end

        # Unary plus
        def +@
          self
        end
      end
    end
  end
end
