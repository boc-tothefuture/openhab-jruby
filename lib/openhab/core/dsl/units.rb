# frozen_string_literal: true

require 'java'

# Import Imperial and SI Units overriding provided values
%i[ImperialUnits SIUnits].each do |type|
  Object.send(:remove_const, type)
  java_import "org.openhab.core.library.unit.#{type}"
end

Object.send(:remove_const, :QuantityType)
java_import org.openhab.core.library.types.QuantityType

module OpenHAB
  module Core
    module DSL
      module Units
        java_import 'tec.uom.se.format.SimpleUnitFormat'
        def unit(unit)
          unit = SimpleUnitFormat.instance.unitFor(unit) if unit.is_a? String
          Thread.current.thread_variable_set(:unit, unit)
          yield
        ensure
          Thread.current.thread_variable_set(:unit, nil)
        end
      end
    end
  end
end
