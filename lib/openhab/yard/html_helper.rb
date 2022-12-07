# frozen_string_literal: true

module OpenHAB
  module YARD
    # @!visibility private
    module HtmlHelper
      def html_markup_markdown(text)
        result = super(text)
        # re-link files in docs/*.md. They're written so they work on github without any
        # processing
        unless serializer.is_a?(::YARD::Server::DocServerSerializer)
          result.gsub!(%r{<a href="(?:[A-Za-z0-9_/-]+/)*([A-Za-z0-9_-]+).md(#[A-Za-z0-9_/-]+)?"},
                       "<a href=\"file.\\1.html\\2\"")
        end

        # wtf commonmarker, you don't generate anchors?!
        result.gsub!(%r{<h(\d)>([A-Za-z0-9 -]+)</h\1>}) do
          id = $2.downcase.tr(" ", "-")
          "<h#{$1} id=\"#{id}\">#{$2}</h#{$1}>"
        end

        result
      end

      # have to completely replace this method. only change is the regex splitting
      # into parts now allows `.` as part of the identifier
      # rubocop:disable Style/NestedTernaryOperator, Style/StringConcatenation, Style/TernaryParentheses
      def format_types(typelist, brackets = true) # rubocop:disable Style/OptionalBooleanParameter
        return unless typelist.is_a?(Array)

        list = typelist.map do |type|
          type = type.gsub(/([<>])/) { h($1) }
          type = type.gsub(/([\w:.]+)/) { $1 == "lt" || $1 == "gt" ? $1 : linkify($1, $1) }
          "<tt>" + type + "</tt>"
        end
        list.empty? ? "" : (brackets ? "(#{list.join(", ")})" : list.join(", "))
      end
      # rubocop:enable Style/NestedTernaryOperator, Style/StringConcatenation, Style/TernaryParentheses
    end
  end
end
