# frozen_string_literal: true

# rubocop:disable Style/ClassAndModuleChildren
class Java::OrgOpenhabCoreItems::GroupItem
  # rubocop:enable Style/ClassAndModuleChildren
  #  include ItemCheck

  def items
    to_a
  end

  def to_a
    all_members.each_with_object([]) { |item, arr| arr << item }
  end
end
