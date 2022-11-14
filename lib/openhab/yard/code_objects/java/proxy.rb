# frozen_string_literal: true

module YARD
  module CodeObjects
    module Java
      module Proxy
        CodeObjects::Proxy.prepend(self)

        def initialize(namespace, name, type = nil)
          if name.match?(/^([a-zA-Z_$][a-zA-Z\d_$]*\.)+/)
            @namespace = Registry.root
            @name = name.to_sym
            @obj = nil
            @imethod = nil
            self.type = type
            return
          end
          super
        end
      end
    end
  end
end
