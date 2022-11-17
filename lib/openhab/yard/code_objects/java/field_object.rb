# frozen_string_literal: true

module YARD
  module CodeObjects
    module Java
      class FieldObject < CodeObjects::ConstantObject
        include Base

        def type
          :constant
        end
      end
    end
  end
end
