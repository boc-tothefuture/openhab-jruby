# frozen_string_literal: true

# rubocop:disable Style/ClassAndModuleChildren
class Java::OrgOpenhabCoreItemsEvents::ItemStateChangedEvent
  # rubocop:enable Style/ClassAndModuleChildren

  def item
    # rubocop:disable Style/GlobalVars
    $ir.get(item_name)
    # rubocop:enable Style/GlobalVars
  end

  def state
    item_state
  end

  def last
    old_item_state
  end
end
