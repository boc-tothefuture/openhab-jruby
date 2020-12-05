# frozen_string_literal: true

require 'java'
require 'openhab/core/log'

# Monkey patch items
require 'openhab/core/dsl/monkey_patch/items/contact_item'
require 'openhab/core/dsl/monkey_patch/items/dimmer_item'
require 'openhab/core/dsl/monkey_patch/items/switch_item'

# rubocop:disable Style/ClassAndModuleChildren
class Java::OrgOpenhabCoreItems::GenericItem
  # rubocop:enable Style/ClassAndModuleChildren
  include Logging
  java_import org.openhab.core.model.script.actions.BusEvent
  java_import org.openhab.core.types.UnDefType

  def command(command)
    logger.trace "Sending Command #{command} to #{self}"
    BusEvent.sendCommand(self, command.to_s)
  end

  def state=(command)
    command(command)
  end

  def item_defined?
    state != UnDefType::UNDEF && state != UnDefType::NULL
  end

  def to_s
    label || name
  end

  def inspect
    toString
  end

  alias << state=
end
