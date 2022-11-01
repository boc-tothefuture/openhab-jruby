# frozen_string_literal: true

module OpenHAB
  module YARD
    module Tags
      module GroupDirective
        ::YARD::Tags::GroupDirective.prepend(self)

        def after_parse
          return if tag.name.empty?
          return unless handler

          object = CodeObjects::GroupObject.new(handler.namespace, tag.name)
          handler.extra_state.group = object
          self.parser = parser.class.new(parser.library)
          parser.state.inside_directive = true
          parser.parse(tag.text, object, handler)
          parser.state.inside_directive = false
          object.docstring = parser.to_docstring # rubocop:disable Lint/UselessSetterCall
        end
      end
    end
  end
end
