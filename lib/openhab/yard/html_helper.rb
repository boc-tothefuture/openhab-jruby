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
    end
  end
end
