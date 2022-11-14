# frozen_string_literal: true

module YARD
  module Handlers
    module JRuby
      module ClassHandler
        include Base

        Ruby::ClassHandler.prepend(self)

        def parse_superclass(superclass)
          infer_java_class(superclass, CodeObjects::Java::ClassObject)&.then { |k| return k }
          super
        end
      end
    end
  end
end
