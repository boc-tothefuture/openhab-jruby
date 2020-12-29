# frozen_string_literal: true

require 'core/duration'

module OpenHAB
  module Core
    module DSL
      module MonkeyPatch
        module Ruby
          module IntegerExtensions
            include OpenHAB::Core

            java_import org.openhab.core.library.types.QuantityType
            java_import 'tec.uom.se.format.SimpleUnitFormat'
            java_import javax.measure.Unit

            def seconds
              Duration.new(temporal_unit: :SECONDS, amount: self)
            end

            def milliseconds
              Duration.new(temporal_unit: :MILLISECONDS, amount: self)
            end

            def minutes
              Duration.new(temporal_unit: :MINUTES, amount: self)
            end

            def hours
              Duration.new(temporal_unit: :HOURS, amount: self)
            end

            alias second seconds
            alias millisecond milliseconds
            alias ms milliseconds
            alias minute minutes
            alias hour hours
          end
        end
      end
    end
  end
end

class Integer
  prepend OpenHAB::Core::DSL::MonkeyPatch::Ruby::IntegerExtensions
end
