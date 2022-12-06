# frozen_string_literal: true

module OpenHAB
  module YARD
    # @!visibility private
    module BaseHelper
      def link_object(obj, title = nil, *)
        ::YARD::Handlers::JRuby::Base.infer_java_class(obj) if obj.is_a?(String)
        obj = ::YARD::Registry.resolve(object, obj, true, true) if obj.is_a?(String)
        if obj.is_a?(::YARD::CodeObjects::Java::Base) && (see = obj.docstring.tag(:see))
          # link to the first see tag
          return linkify(see.name, title&.to_s || see.text)
        end

        super
      end
    end
  end
end
