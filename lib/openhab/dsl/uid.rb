# frozen_string_literal: true

module OpenHAB
  module DSL
    java_import org.openhab.core.common.AbstractUID
    java_import org.openhab.core.thing.ThingTypeUID

    # Adds methods to core OpenHAB AbstractUID to make it more natural in Ruby
    class AbstractUID
      # implicit conversion to string
      alias to_str to_s
      # inspect result is just the string representation
      alias inspect to_s

      # compares if equal to `other`, including string conversion
      # @return [true, false]
      def ==(other)
        return true if equals(other)

        to_s == other
      end
    end

    # Adds methods to core OpenHAB ThingUID to make it more natural in Ruby
    class ThingUID
      # Returns the id of the binding this thing belongs to
      # @return [String]
      def binding_id
        get_segment(0)
      end
    end

    # Adds methods to core OpenHAB ThingTypeUID to make it more natural in Ruby
    class ThingTypeUID
      # Returns the id of the binding this thing type belongs to
      # @return [String]
      def binding_id
        get_segment(0)
      end
    end

    # have to remove == from all descendant classes so that they'll inherit
    # the new implementation
    [org.openhab.core.items.MetadataKey,
     org.openhab.core.thing.UID,
     org.openhab.core.thing.ChannelUID,
     org.openhab.core.thing.ChannelGroupUID,
     org.openhab.core.thing.ThingUID,
     org.openhab.core.thing.ThingTypeUID,
     org.openhab.core.thing.type.ChannelTypeUID,
     org.openhab.core.thing.type.ChannelGroupTypeUID].each do |klass|
      klass.remove_method(:==)
    end
  end
end
