# frozen_string_literal: true

require 'java'

# Import Imperial and SI Units overriding provided values
%i[Units ImperialUnits SIUnits].each do |type|
  Object.send(:remove_const, type)
  java_import "org.openhab.core.library.unit.#{type}"
end

Object.send(:remove_const, :QuantityType)
java_import org.openhab.core.library.types.QuantityType

module OpenHAB
  module DSL
    #
    # Provides support for interacting with OpenHAB Units of Measurement
    #
    module Units
      module_function

      # @return The default unit for the current thread
      def unit(unit = nil, &block)
        return with_unit(unit, &block) if unit || block # back-compat

        Thread.current[:unit]
      end

      #
      # Sets a thread local variable to the supplied unit such that classes operating inside the block
      # can perform automatic conversions to the supplied unit for NumberItems
      #
      # @param [Object] unit OpenHAB Unit or String representing unit
      # @yield [] Block executed in context of the supplied unit
      #
      def with_unit(unit)
        unit = org.openhab.core.types.util.UnitUtils.parse_unit(unit) if unit.is_a? String
        Thread.current[:unit] = unit
        yield
      ensure
        Thread.current[:unit] = nil
      end
    end
  end
end
