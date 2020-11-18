# frozen_string_literal: true

require 'core/log'

module Item
  java_import org.openhab.core.automation.util.TriggerBuilder
  java_import org.openhab.core.config.core.Configuration

  import Logging

  def changed(*items, to: nil, from: nil)
    items.flatten.each do |item|
      config = { 'itemName' => item.name }
      config['state'] = to.to_s unless to.nil?
      config['previousState'] = from.to_s unless from.nil?
      logger.trace("Creating Change Trigger for #{config}")
      @triggers << TriggerBuilder.create
                                 .with_id(uuid)
                                 .with_type_uid('core.ItemStateChangeTrigger')
                                 .with_configuration(Configuration.new(config))
                                 .build
    end
  end
end
