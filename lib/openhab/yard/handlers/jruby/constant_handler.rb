# frozen_string_literal: true

module YARD
  module Handlers
    module JRuby
      module ConstantHandler
        include Base

        Ruby::ConstantHandler.prepend(self)

        def process_constant(statement)
          infer_java_class(statement[1], nil, statement.comments)
          super
        end
      end
    end
  end
end
