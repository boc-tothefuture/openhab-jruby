# frozen_string_literal: true

require 'java'
require 'core/log'

# Monkey patch types
require 'core/dsl/monkey_patch/type/open_closed_type'

# rubocop:disable Style/ClassAndModuleChildren
class Java::OrgOpenhabCoreItems::GenericItem
  # rubocop:enable Style/ClassAndModuleChildren
  include Logging
  java_import org.openhab.core.model.script.actions.BusEvent

  def command(command)
    logger.trace "Sending Command #{command} to #{self}"
    BusEvent.sendCommand(self, command.to_s)
  end

  def state=(command)
    command(command)
  end

  def to_s
    label || name
  end

  def inspect
    toString
  end

  alias << state=
end
