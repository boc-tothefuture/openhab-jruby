# frozen_string_literal: true

require "yard"
require "coderay"

module YARD::CodeRay::HTMLHelper # rubocop:disable Style/ClassAndModuleChildren
  CodeRay::Scanners.list.each do |scanner|
    define_method("html_syntax_highlight_#{scanner}") do |source|
      CodeRay.scan(source, scanner).html
    end
  end
end

# Inject Coderay highlighting into YARD
YARD::Templates::Helpers::HtmlHelper.include YARD::CodeRay::HTMLHelper
