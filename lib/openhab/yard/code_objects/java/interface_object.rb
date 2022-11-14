# frozen_string_literal: true

module YARD
  module CodeObjects
    module Java
      class InterfaceObject < CodeObjects::ModuleObject
        include Base

        def type
          :module
        end
      end
    end
  end
end
