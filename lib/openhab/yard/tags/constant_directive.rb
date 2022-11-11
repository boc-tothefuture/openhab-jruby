# frozen_string_literal: true

module OpenHAB
  module YARD
    module Tags
      class ConstantDirective < ::YARD::Tags::Directive
        def call
          return unless handler

          ::YARD::CodeObjects::ConstantObject.new(handler.namespace, tag.name.to_sym) do |obj|
            obj.value = ""
            obj.docstring = tag.text
          end
        end

        ::YARD::Tags::Library.define_directive :constant, :with_title_and_text, self
      end
    end
  end
end
