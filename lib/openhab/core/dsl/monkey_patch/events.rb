# frozen_string_literal: true

# rubocop:disable Style/ClassAndModuleChildren
class Java::OrgOpenhabCoreItemsEvents::ItemStateChangedEvent
  # rubocop:enable Style/ClassAndModuleChildren

  def item
    $ir.get(item_name)
  end

  def state
    item_state
  end

  def last
    old_item_state
  end
end
