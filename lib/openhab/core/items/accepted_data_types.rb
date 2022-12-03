# frozen_string_literal: true

module OpenHAB
  module Core
    module Items
      class << self
        # @!visibility private
        def prepend_accepted_data_types
          concrete_item_classes.each do |k|
            k.prepend(AcceptedDataTypes)
          end
        end
      end

      module AcceptedDataTypes
        # @see Item#accepted_command_types
        def accepted_command_types
          super.map { |k| k.is_a?(java.lang.Class) ? k.ruby_class : k }
        end

        # @see Item#accepted_data_types
        def accepted_data_types
          super.map { |k| k.is_a?(java.lang.Class) ? k.ruby_class : k }
        end
      end
      private_constant :AcceptedDataTypes
    end
  end
end
