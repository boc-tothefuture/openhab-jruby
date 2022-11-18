# frozen_string_literal: true

module OpenHAB
  module Core
    #
    # Manages access to OpenHAB entities
    #
    # You can access OpenHAB items and things directly using their name, anywhere `EntityLookup` is available.
    #
    # @note Thing UIDs are separated by a colon `:`. Since it is not a valid symbol for an identifier,
    #   it must be replaced with an underscore `_`. So to access `astro:sun:home`, use `astro_sun_home`
    #   as an alternative to `things["astro:sun:home"]`
    #
    # @see OpenHAB::DSL.items items[]
    # @see OpenHAB::DSL.things things[]
    #
    # @example Accessing Items and Groups
    #   gAll_Lights       # Access the gAll_Lights group. It is the same as items["gAll_Lights"]
    #   Kitchen_Light.on  # The OpenHAB object for the Kitchen_Light item and send an ON command
    #
    # @example Accessing Things
    #   smtp_mail_local.send_mail('me@example.com', 'Subject', 'Dear Person, ...')
    #   # Is equivalent to:
    #   things['smtp:mail:local'].send_mail('me@example.com', 'Subject', 'Dear Person, ...')
    #
    module EntityLookup
      #
      # Automatically looks up OpenHAB items and things in appropriate registries
      #
      # @return [GenericItem, Things::Thing, nil]
      #
      def method_missing(method, *args, &block)
        logger.trace("method missing, performing OpenHab Lookup for: #{method}")
        EntityLookup.lookup_entity(method) || super
      end

      # @!visibility private
      def respond_to_missing?(method_name, _include_private = false)
        logger.trace("Checking if OpenHAB entities exist for #{method_name}")
        method_name = method_name.to_s if method_name.is_a?(Symbol)

        method_name == "scriptLoaded" ||
          method_name == "scriptUnloaded" ||
          EntityLookup.lookup_entity(method_name) ||
          super
      end

      #
      # Looks up an OpenHAB entity
      #  items are checked first, then things
      #
      # @!visibility private
      #
      # @param [String] name of entity to lookup in item or thing registry
      #
      # @return [GenericItem, Things::Thing, nil]
      #
      def self.lookup_entity(name)
        lookup_item(name) || lookup_thing_const(name)
      end

      #
      # Looks up a Thing in the OpenHAB registry
      #
      # @!visibility private
      #
      # @param [String] uid name of Thing to lookup in Thing registry
      #
      # @return [Things::Thing, nil]
      #
      def self.lookup_thing(uid)
        logger.trace("Looking up thing '#{uid}'")
        uid = uid.to_s if uid.is_a?(Symbol)

        uid = Things::ThingUID.new(uid) unless uid.is_a?(Things::ThingUID)
        thing = $things.get(uid)
        return unless thing

        logger.trace("Retrieved Thing(#{thing}) from registry for uid: #{uid}")
        Things::Proxy.new(thing)
      end

      #
      # Looks up a Thing in the OpenHAB registry replacing `_` with `:`
      #
      # @!visibility private
      #
      # @param [String] name of Thing to lookup in Thing registry
      #
      # @return [Things::Thing, nil]
      #
      def self.lookup_thing_const(name)
        name = name.to_s if name.is_a?(Symbol)

        if name.is_a?(String)
          # Thing UIDs have at least 3 segments, separated by `_`
          return if name.count("_") < 2

          # Convert from _ syntax to :
          name = name.tr("_", ":")
        end
        lookup_thing(name)
      end

      #
      # Lookup OpenHAB items in item registry
      #
      # @!visibility private
      #
      # @param [String] name of item to lookup
      #
      # @return [GenericItem, nil]
      #
      def self.lookup_item(name)
        logger.trace("Looking up item '#{name}'")
        name = name.to_s if name.is_a?(Symbol)
        item = $ir.get(name)
        Items::Proxy.new(item) unless item.nil?
      end
    end
  end
end

#
# Implements const_missing to return OpenHAB items or things if mapping to missing name if they exist
#
# @param [String] name Capital string that was not set as a constant and to be looked up
#
# @return [Object] OpenHAB Item or Thing if their name exist in OpenHAB item and thing regestries
#
def Object.const_missing(name)
  OpenHAB::Core::EntityLookup.lookup_entity(name) || super
end
