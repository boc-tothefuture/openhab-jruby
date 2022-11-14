# frozen_string_literal: true

module OpenHAB
  module YARD
    # @!visibility private
    module HtmlHelper
      def html_markup_markdown(text)
        result = super

        # re-link files in docs/*.md. They're written so they work on github without any
        # processing
        result.gsub!(%r{<a href="(?:[A-Za-z0-9_/-]+/)*([A-Za-z0-9_-]+).md(#[A-Za-z0-9_/-]+)?"},
                     "<a href=\"file.\\1.html\\2\"")
        result
      end

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
