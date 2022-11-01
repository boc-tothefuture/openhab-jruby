# frozen_string_literal: true

require_relative "yard/code_objects/group_object"
require_relative "yard/html_helper"
require_relative "yard/tags/group_directive"
require_relative "yard/tags/library"

YARD::Templates::Template.extra_includes << ->(opts) { OpenHAB::YARD::HtmlHelper if opts.format == :html }
YARD::Templates::Engine.register_template_path File.expand_path("../../templates", __dir__)
