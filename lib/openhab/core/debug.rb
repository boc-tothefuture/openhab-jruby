# frozen_string_literal: true

require 'pp'
require 'core/log'
require 'core/dsl/things'

module Debug
  include Logging
  include Things

  def debug_variables
    pp "Instance #{instance_variables}"
    pp "Global #{global_variables}"
    pp "Load Path #{$LOAD_PATH}"
    # pp "Constants #{Module.constants}"
  end

  def debug_openhab
    logger.debug { "Things - Count #{things.size}" }
    things.each do |thing|
      logger.debug { "Thing:(#{thing.label})  UID:(#{thing.uid}) Channels(#{thing.channels.map(&:uid).join(', ')})" }
    end
    # logger.debug { $things.getAll.join(", ") }
  end
end
