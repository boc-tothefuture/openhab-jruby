# frozen_string_literal: true

require 'java'

module Items
  # rubocop: disable Style/GlobalVars
  java_import org.openhab.core.items.GroupItem
  def items
    $ir.items.reject { |item| item.is_a? GroupItem }
  end

  def groups
    $ir.items.select { |item| item.is_a? GroupItem }
  end

  # rubocop: enable Style/GlobalVars
end
