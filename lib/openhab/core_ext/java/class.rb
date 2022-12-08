# frozen_string_literal: true

module OpenHAB
  module CoreExt
    module Java
      Class = java.lang.Class

      # Extensions to Class
      class Class
        #
        # `self`, all superclasses and interfaces, recursively.
        #
        # @return [Array<Class>]
        #
        def ancestors
          ([self] +
            Array(superclass&.ancestors) +
            interfaces.flat_map(&:ancestors)).uniq
        end

        #
        # `self`, all superclasses and interfaces, recursively.
        #
        # @return [Array<java.lang.reflect.Type>]
        #
        def generic_ancestors
          ancestors.flat_map do |klass|
            Array(klass.generic_superclass) + klass.generic_interfaces
          end.uniq
        end
      end
    end
  end
end
