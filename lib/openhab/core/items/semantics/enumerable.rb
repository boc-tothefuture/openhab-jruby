# frozen_string_literal: true

# Additions to Enumerable to allow easily filtering and commanding groups of items
module Enumerable
  # Returns a new array of items that have at least one of the given tags
  # @return [Array<OpenHAB::Core::Items::GenericItem>]
  def tagged(*tags)
    reject { |i| (tags & i.tags.to_a).empty? }
  end

  # Returns a new array of items that do not have any of the given tags
  # @return [Array<OpenHAB::Core::Items::GenericItem>]
  def not_tagged(*tags)
    select { |i| (tags & i.tags.to_a).empty? }
  end

  # Returns a new array of items that are a member of at least one of the given groups
  # @return [Array<OpenHAB::Core::Items::GenericItem>]
  def member_of(*groups)
    reject { |i| (groups.map(&:name) & i.group_names).empty? }
  end

  # Returns a new array of items that are not a member of any of the given groups
  # @return [Array<OpenHAB::Core::Items::GenericItem>]
  def not_member_of(*groups)
    select { |i| (groups.map(&:name) & i.group_names).empty? }
  end

  # Send a command to every item in the collection
  # @return [self]
  def command(command)
    each { |i| i.command(command) }
  end

  # Update the state of every item in the collection
  # @return [self]
  def update(state)
    each { |i| i.update(state) }
  end

  # Returns the group members the elements
  # @return [Array<OpenHAB::Core::Items::GenericItem>]
  def members
    grep(OpenHAB::Core::Items::GroupItem).flat_map(&:members)
  end

  # @!method refresh
  #   Send the `REFRESH` command to every item in the collection
  #   @return [self]

  # @!method on
  #   Send the `ON` command to every item in the collection
  #   @return [self]

  # @!method off
  #   Send the `OFF` command to every item in the collection
  #   @return [self]

  # @!method up
  #   Send the `UP` command to every item in the collection
  #   @return [self]

  # @!method down
  #   Send the `DOWN` command to every item in the collection
  #   @return [self]

  # @!method stop
  #   Send the `STOP` command to every item in the collection
  #   @return [self]

  # @!method move
  #   Send the `MOVE` command to every item in the collection
  #   @return [self]

  # @!method increase
  #   Send the `INCREASE` command to every item in the collection
  #   @return [self]

  # @!method decrease
  #   Send the `DECREASE` command to every item in the collection
  #   @return [self]

  # @!method play
  #   Send the `PLAY` command to every item in the collection
  #   @return [self]

  # @!method pause
  #   Send the `pause` command to every item in the collection
  #   @return [self]

  # @!method rewind
  #   Send the `REWIND` command to every item in the collection
  #   @return [self]

  # @!method fast_forward
  #   Send the `FAST_FORWARD` command to every item in the collection
  #   @return [self]

  # @!method next
  #   Send the `NEXT` command to every item in the collection
  #   @return [self]

  # @!method previous
  #   Send the `PREVIOUS` command to every item in the collection
  #   @return [self]

  # @!visibility private
  # can't use `include`, because Enumerable has already been included
  # in other classes
  def ensure
    OpenHAB::DSL::Ensure::GenericItemDelegate.new(self)
  end
end
