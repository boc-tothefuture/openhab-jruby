# frozen_string_literal: true

module OpenHAB
  module Core
    module Actions
      # @see org.openhab.core.transform.actions.Transformation
      class Transformation
        class << self
          # @!visibility private
          alias_method :transform_raw, :transform if instance_methods.include?(:say)

          #
          # Applies a transformation of a given type with some function to a value.
          #
          # @param [String, Symbol] type The transformation type, e.g. REGEX
          #   or MAP
          # @param [String, Symbol] function The function to call. This value depends
          #   on the transformation type
          # @param [String] value The value to apply the transformation to
          # @return [String] the transformed value, or the original value if an error occurred
          #
          # @example Run a transformation
          #   Transformation.transform(:map, "myfan.map", 0)
          #
          def transform(type, function, value)
            transform_raw(type.to_s.upcase, function.to_s, value.to_s)
          end
        end
      end
    end
  end
end
