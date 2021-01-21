# frozen_string_literal: true

require 'java'

#
# Monkey patch with ruby style accesors
#
# rubocop:disable Style/ClassAndModuleChildren
class Java::OrgOpenhabCoreItemsEvents::ItemCommandEvent
  # rubocop:enable Style/ClassAndModuleChildren

  alias command item_command
end
