# frozen_string_literal: true

module OpenHAB
  module Core
    #
    # Manages access to openHAB entities
    #
    # You can access openHAB items and things directly using their name, anywhere `EntityLookup` is available.
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
    #   Kitchen_Light.on  # The openHAB object for the Kitchen_Light item and send an ON command
    #
    # @example Accessing Things
    #   smtp_mail_local.send_mail('me@example.com', 'Subject', 'Dear Person, ...')
    #   # Is equivalent to:
    #   things['smtp:mail:local'].send_mail('me@example.com', 'Subject', 'Dear Person, ...')
    #
    module EntityLookup
      # @!visibility private
      module ClassMethods
        # @!attribute [w] create_dummy_items
        # @return [true,false]
        def create_dummy_items=(value)
          @create_dummy_items = value
        end

        # @return [Boolean] if dummy items should be created in this context
        def create_dummy_items?
          @create_dummy_items
        end
      end

      # @!visibility private
      def self.included(klass)
        klass.singleton_class.include(ClassMethods)
      end

      #
      # Automatically looks up openHAB items and things in appropriate registries
      #
      # @return [Item, Things::Thing, nil]
      #
      def method_missing(method, *)
        logger.trace("method missing, performing openHAB Lookup for: #{method}")
        EntityLookup.lookup_entity(method,
                                   create_dummy_items: self.class.respond_to?(:create_dummy_items?) &&
                                     self.class.create_dummy_items?) || super
      end

      # @!visibility private
      def respond_to_missing?(method, *)
        logger.trace("Checking if openHAB entities exist for #{method}")
        EntityLookup.lookup_entity(method) || super
      end

      # @!visibility private
      def instance_eval_with_dummy_items(&block)
        DSL::ThreadLocal.thread_local(openhab_create_dummy_items: self.class.create_dummy_items?) do
          instance_eval(&block)
        end
      end

      class << self
        #
        # Looks up an openHAB entity
        #  items are checked first, then things
        #
        # @!visibility private
        #
        # @param [String] name of entity to lookup in item or thing registry
        # @param [true, false] create_dummy_items If a dummy {Item} should be created if an actual item can't be found
        #
        # @return [Item, Things::Thing, nil]
        #
        def lookup_entity(name, create_dummy_items: false)
          # make sure we have a nil return
          create_dummy_items = nil if create_dummy_items == false
          lookup_item(name) || lookup_thing_const(name) || (create_dummy_items && Items::Proxy.new(name.to_sym))
        end

        #
        # Looks up a Thing in the openHAB registry
        #
        # @!visibility private
        #
        # @param [String] uid name of Thing to lookup in Thing registry
        #
        # @return [Things::Thing, nil]
        #
        def lookup_thing(uid)
          logger.trace("Looking up thing '#{uid}'")
          uid = uid.to_s if uid.is_a?(Symbol)

          uid = Things::ThingUID.new(uid) unless uid.is_a?(Things::ThingUID)
          thing = $things.get(uid)
          return unless thing

          logger.trace("Retrieved Thing(#{thing}) from registry for uid: #{uid}")
          Things::Proxy.new(thing)
        end

        #
        # Looks up a Thing in the openHAB registry replacing `_` with `:`
        #
        # @!visibility private
        #
        # @param [String] name of Thing to lookup in Thing registry
        #
        # @return [Things::Thing, nil]
        #
        def lookup_thing_const(name)
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
        # @return [Item, nil]
        #
        def lookup_item(name)
          logger.trace("Looking up item '#{name}'")
          name = name.to_s if name.is_a?(Symbol)
          item = $ir.get(name)
          Items::Proxy.new(item) unless item.nil?
        end
      end
    end
  end
end

#
# Implements const_missing to return openHAB items or things if mapping to missing name if they exist
#
# @param [String] name Capital string that was not set as a constant and to be looked up
#
# @return [Object] openHAB Item or Thing if their name exist in openHAB item and thing regestries
#
def Object.const_missing(name)
  OpenHAB::Core::EntityLookup.lookup_entity(name,
                                            create_dummy_items: Thread.current[:openhab_create_dummy_items]) || super
end
