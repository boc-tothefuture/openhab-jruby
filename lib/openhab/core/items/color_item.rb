# frozen_string_literal: true

require_relative "dimmer_item"

module OpenHAB
  module Core
    module Items
      java_import org.openhab.core.library.items.ColorItem

      #
      # {ColorItem} represents a color values, e.g. for LED lights.
      #
      # Note that it inherits from {DimmerItem}, so you can call {#on}, {#off},
      # {#on?}, {#off?}, etc. on it. Its state type is an {Types::HSBType},
      # which is stored as Hue, Saturation, and Brightness, but has easy
      # helpers for working with RGB values of various forms.
      #
      # @example Sending commands
      #   HueBulb << "#ff0000" # send 'red' as a command
      #   HueBulb << {red: 255, green: 0, blue: 0} # send 'red' as a command
      #   HueBulb << {r: 255, g: 0, b: 0} # send 'red' as a command
      #   HueBulb << {hue: 100, saturation: 0, brightness: 0} # send HSB components as a hash
      #   HueBulb << {h: 100, s: 0, b: 0} # send HSB components  as a hash
      #   HueBulb.on
      #   HueBulb.dim
      #
      # @example Inspect state
      #   HueBulb.on? # => true
      #   HueBulb.state.red # => 100%
      #   HueBulb.state.hue # => 0 °
      #   HueBulb.state.brightness # => 100%
      #   HueBulb.state.to_rgb # => [100%, 0%, 0%]
      #   HueBulb.state.rgb # => 16711680
      #   HueBulb.state.to_hex # => "0xff0000"
      #   HueBulb.state.on? # => true
      #   HueBulb.state.red.to_byte # => 255
      #   HueBulb.state.blue.to_byte # => 0
      #   HueBulb.state.to_h # => {:hue=>0 °, :saturation=>100%, :brightness=>100%}
      #   HueBulb.state.to_h(:rgb) # => {:red=>255, :green=>0, :blue=>0}
      #   HueBulb.state.to_a # => [0 °, 100%, 100%]
      #   HueBulb.state.to_a(:rgb) # => [255, 0, 0]
      #
      # @!attribute [r] state
      #   @return [Types::HSBType, nil]
      #
      class ColorItem < DimmerItem
        # string commands aren't allowed on ColorItems, so try to implicitly
        # convert it to an HSBType
        # @!visibility private
        def format_type(command)
          return format_hash(command.to_hash) if command.respond_to?(:to_hash)
          return Types::HSBType.new(command) if command.respond_to?(:to_str)

          super
        end

        private

        # Mapping of hash values sets to conversion methods
        HASH_KEYS = { %i[r g b] => :from_rgb,
                      %i[red green blue] => :from_rgb,
                      %i[h s b] => :from_hsb,
                      %i[hue saturation brightness] => :from_hsb }.freeze

        def format_hash(hash)
          hash = hash.transform_keys(&:to_sym)
          HASH_KEYS.each do |key_set, method|
            values = hash.values_at(*key_set).compact
            return Types::HSBType.public_send(method, *values) if values.length == 3
          end
          raise ArgumentError, "Supplied hash (#{hash}) must contain one of the following keysets #{keys.keys}"
        end
      end
    end
  end
end
