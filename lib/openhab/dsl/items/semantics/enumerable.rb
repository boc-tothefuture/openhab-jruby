# frozen_string_literal: true

# Additions to Enumerable to allow easily filtering and commanding groups of items
module Enumerable
  # Returns a new array of items that have at least one of the given tags
  def tagged(*tags)
    reject { |i| (tags & i.tags.to_a).empty? }
  end

  # Returns a new array of items that do not have any of the given tags
  def not_tagged(*tags)
    select { |i| (tags & i.tags.to_a).empty? }
  end

  # Returns a new array of items that are a member of at least one of the given groups
  def member_of(*groups)
    reject { |i| (groups.map(&:name) & i.group_names).empty? }
  end

  # Returns a new array of items that are not a member of any of the given groups
  def not_member_of(*groups)
    select { |i| (groups.map(&:name) & i.group_names).empty? }
  end

  # Send a command to every item in the collection
  def command(command)
    each { |i| i.command(command) }
  end

  # Update the state of every item in the collection
  def update(state)
    each { |i| i.update(state) }
  end

  # @!method refresh
  #   Send the +REFRESH+ command to every item in the collection

  # @!method on
  #   Send the +ON+ command to every item in the collection

  # @!method off
  #   Send the +OFF+ command to every item in the collection

  # @!method up
  #   Send the +UP+ command to every item in the collection

  # @!method down
  #   Send the +DOWN+ command to every item in the collection

  # @!method stop
  #   Send the +STOP+ command to every item in the collection

  # @!method move
  #   Send the +MOVE+ command to every item in the collection

  # @!method increase
  #   Send the +INCREASE+ command to every item in the collection

  # @!method decrease
  #   Send the +DECREASE+ command to every item in the collection

  # @!method play
  #   Send the +PLAY+ command to every item in the collection

  # @!method pause
  #   Send the +pause+ command to every item in the collection

  # @!method rewind
  #   Send the +REWIND+ command to every item in the collection

  # @!method fast_forward
  #   Send the +FAST_FORWARD+ command to every item in the collection

  # @!method next
  #   Send the +NEXT+ command to every item in the collection

  # @!method previous
  #   Send the +PREVIOUS+ command to every item in the collection
end
