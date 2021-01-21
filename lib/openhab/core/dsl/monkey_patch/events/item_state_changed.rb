# frozen_string_literal: true

require 'java'

#
# MonkeyPatch with ruby style accessors
#
# rubocop:disable Style/ClassAndModuleChildren
class Java::OrgOpenhabCoreItemsEvents::ItemStateChangedEvent
  # rubocop:enable Style/ClassAndModuleChildren

  #
  # Get the item that caused the state change
  #
  # @return [Item] Item that caused state change
  #
  def item
    # rubocop:disable Style/GlobalVars
    $ir.get(item_name)
    # rubocop:enable Style/GlobalVars
  end

  alias state item_state
  alias last old_item_state
end
