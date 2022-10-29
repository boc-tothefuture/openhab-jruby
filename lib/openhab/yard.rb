# frozen_string_literal: true

require_relative "yard/html_helper"

YARD::Templates::Template.extra_includes << ->(opts) { OpenHAB::YARD::HtmlHelper if opts.format == :html }

module OpenHAB
  # @!visibility private
  module YARD
  end
end
