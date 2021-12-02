# frozen_string_literal: true

require_relative 'enumerable'

module OpenHAB
  module DSL
    # Module for implementing semantics helper methods on [GenericItem]
    #
    # Wraps https://www.openhab.org/javadoc/latest/org/openhab/core/model/script/actions/semantics,
    # as well as adding a few additional convenience methods.
    # Also includes Classes for each semantic tag.
    #
    # Be warned that the Semantic model is stricter than can actually be
    # described by tags and groups on an Item. It makes assumptions that any
    # given item only belongs to one semantic type (Location, Equipment, Point).
    #
    # See https://github.com/openhab/openhab-core/blob/main/bundles/org.openhab.core.semantics/model/SemanticTags.csv
    module Semantics
      # @!visibility private
      # import the actual semantics action
      SemanticsAction = org.openhab.core.model.script.actions.Semantics
      private_constant :SemanticsAction

      # import all the semantics constants
      [org.openhab.core.semantics.model.point.Points,
       org.openhab.core.semantics.model.property.Properties,
       org.openhab.core.semantics.model.equipment.Equipments,
       org.openhab.core.semantics.model.location.Locations].each do |parent_tag|
        parent_tag.stream.for_each do |tag|
          const_set(tag.simple_name.to_sym, tag.ruby_class)
        end
      end

      # put ourself into the global namespace, replacing the action
      ::Semantics = self # rubocop:disable Naming/ConstantName

      # Checks if this Item is a Location
      #
      # This is implemented as checking if the item's semantic_type
      # is a Location. I.e. an Item has a single semantic_type.
      #
      # @return [true, false]
      def location?
        SemanticsAction.location?(self)
      end

      # Checks if this Item is an Equipment
      #
      # This is implemented as checking if the item's semantic_type
      # is an Equipment. I.e. an Item has a single semantic_type.
      #
      # @return [true, false]
      def equipment?
        SemanticsAction.equipment?(self)
      end

      # Checks if this Item is a Point
      #
      # This is implemented as checking if the item's semantic_type
      # is a Point. I.e. an Item has a single semantic_type.
      #
      # @return [true, false]
      def point?
        SemanticsAction.point?(self)
      end

      # Checks if this Item has any semantic tags
      # @return [true, false]
      def semantic?
        !!semantic_type
      end

      # Gets the related Location Item of this Item.
      #
      # Returns +self+ if this Item is a Location. Otherwise, checks ancestor
      # groups one level at a time, returning the first Location Item found.
      #
      # @return [GenericItem, nil]
      def location
        SemanticsAction.get_location(self)
      end

      # Returns the sub-class of [Location] related to this Item.
      #
      # In other words, the semantic_type of this Item's Location.
      #
      # @return [Class]
      def location_type
        SemanticsAction.get_location_type(Self)&.ruby_class
      end

      # Gets the related Equipment Item of this Item.
      #
      # Returns +self+ if this Item is an Equipment. Otherwise, checks ancestor
      # groups one level at a time, returning the first Equipment Item found.
      #
      # @return [GenericItem, nil]
      def equipment
        SemanticsAction.get_equipment(self)
      end

      # Returns the sub-class of [Equipment] related to this Item.
      #
      # In other words, the semantic_type of this Item's Equipment.
      #
      # @return [Class]
      def equipment_type
        SemanticsAction.get_equipment_type(self)&.ruby_class
      end

      # Returns the sub-class of [Point] this Item is tagged with.
      #
      # @return [Class]
      def point_type
        SemanticsAction.get_point_type(self)&.ruby_class
      end

      # Returns the sub-class of [Property] this Item is tagged with.
      # @return [Class]
      def property_type
        SemanticsAction.get_property_type(self)&.ruby_class
      end

      # Returns the sub-class of [Tag] this Item is tagged with.
      #
      # It will only return the first applicable Tag, preferring
      # a sub-class of [Location], [Equipment], or [Point] first,
      # and if none of those are found, looks for a [Property].
      # @return [Class]
      def semantic_type
        SemanticsAction.get_semantic_type(self)&.ruby_class
      end

      # Return the related Point Items.
      #
      # Searches this Equipment Item for Points that are tagged appropriately.
      #
      # If called on a Point Item, it will automatically search for sibling Points
      # (and remove itself if found).
      #
      # @example Get all points for a TV
      #   eGreatTV.points
      # @example Search an Equipment item for its switch
      #   eGuestFan.points(Semantics::Switch) # => [GuestFan_Dimmer]
      # @example Search a Thermostat item for its current temperature item
      #   eFamilyThermostat.points(Semantics::Status, Semantics::Temperature)
      #   # => [FamilyThermostat_AmbTemp]
      # @example Search a Thermostat item for is setpoints
      #   eFamilyThermostat.points(Semantics::Control, Semantics::Temperature)
      #   # => [FamilyThermostat_HeatingSetpoint, FamilyThermostat_CoolingSetpoint]
      # @example Given a A/V receiver's input item, search for it's power item
      #   FamilyReceiver_Input.points(Semantics::Switch) # => FamilyReceiver_Switch
      #
      # @param [Class] point_or_property_types
      #   Pass 1 or 2 classes that are sub-classes of [Point] or [Property].
      #   Note that when comparing against semantic tags, it does a sub-class check.
      #   So if you search for [Control], you'll get items tagged with [Switch].
      # @return [Array<GenericItem>]
      def points(*point_or_property_types)
        # automatically search the parent equipment (or location?!) for sibling points
        unless equipment? || location?
          result = (equipment || location)&.points(*point_or_property_types) || []
          # remove self. but avoid state comparisons
          result.delete_if { |item| item.eql?(self) }
          return result
        end

        members.points(*point_or_property_types)
      end
    end

    GenericItem.include(Semantics)
  end
end

# Additions to Enumerable to allow easily filtering groups of items based on the semantic model
module Enumerable
  # Returns a new array of items that are a semantics Location (optionally of the given type)
  def sublocations(type = nil)
    raise ArgumentError, 'type must be a subclass of Location' if type && !(type < OpenHAB::DSL::Semantics::Location)

    result = select(&:location?)
    result.select! { |i| i.location_type <= type } if type

    result
  end

  # Returns a new array of items that are a semantics equipment (optionally of the given type)
  #
  # @example Get all TVs in a room
  #   lGreatRoom.equipments(Semantics::Screen)
  def equipments(type = nil)
    raise ArgumentError, 'type must be a subclass of Equipment' if type && !(type < OpenHAB::DSL::Semantics::Equipment)

    result = select(&:equipment?)
    result.select! { |i| i.equipment_type <= type } if type

    result
  end

  # Returns a new array of items that are semantics points (optionally of a given type)
  #
  # @example Get all the power switch items for every equipment in a room
  #   lGreatRoom.equipments.flat_map(&:members).points(Semantics::Switch)
  def points(*point_or_property_types) # rubocop:disable Metrics
    unless (0..2).cover?(point_or_property_types.length)
      raise ArgumentError, "wrong number of arguments (given #{point_or_property_types.length}, expected 1..2)"
    end
    unless point_or_property_types.all? do |tag|
             tag < OpenHAB::DSL::Semantics::Point || tag < OpenHAB::DSL::Semantics::Property
           end
      raise ArgumentError, 'point_or_property_types must all be a subclass of Point or Property'
    end
    if point_or_property_types.count { |tag| tag < OpenHAB::DSL::Semantics::Point } > 1 ||
       point_or_property_types.count { |tag| tag < OpenHAB::DSL::Semantics::Property } > 1
      raise ArgumentError, 'point_or_property_types cannot both be a subclass of Point or Property'
    end

    select do |point|
      next unless point.point?

      point_or_property_types.all? do |tag|
        (tag < OpenHAB::DSL::Semantics::Point && point.point_type <= tag) ||
          (tag < OpenHAB::DSL::Semantics::Property && point.property_type <= tag)
      end
    end
  end
end
