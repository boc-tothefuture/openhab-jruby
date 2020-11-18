# frozen_string_literal: true

require 'java'
require 'core/duration'

module Actions
  java_import org.openhab.core.model.script.actions.ScriptExecution
  java_import java.time.ZonedDateTime

  def after(duration, &block)
    ScriptExecution.createTimer(ZonedDateTime.now.plus(Java::JavaTime::Duration.ofMillis(duration.to_ms)), block)
  end
end
