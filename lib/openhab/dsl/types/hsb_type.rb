# frozen_string_literal: true

require 'java'
require_relative 'percent_type'

module OpenHAB
  module DSL
    module Types
      java_import org.openhab.core.library.types.HSBType

      # global alias
      ::HSBType = HSBType

      # Adds methods to core OpenHAB HSBType to make it more natural in Ruby
      class HSBType < PercentType
        # @!parse BLACK = BLACK # @return [HSBType]
        # @!parse WHITE = WHITE # @return [HSBType]
        # @!parse RED = RED # @return [HSBType]
        # @!parse GREEN = GREEN # @return [HSBType]
        # @!parse BLUE = BLUE # @return [HSBType]

        # conversion to QuantityType doesn't make sense on HSBType
        undef_method :|

        remove_method :==

        # r, g, b as an array of symbols
        RGB_KEYS = %i[r g b].freeze
        private_constant :RGB_KEYS

        class << self
          # @!method from_rgb(r, g, b)
          #   Create HSBType from RGB values
          #   @param r [Integer] Red component (0-255)
          #   @param g [Integer] Green component (0-255)
          #   @param b [Integer] Blue component (0-255)
          #   @return [HSBType]

          # @!method from_xy(x, y)
          #   Create HSBType representing the provided xy color values in CIE XY color model
          #   @param x [Float]
          #   @param y [Float]
          #   @return [HSBType]

          # Create HSBType from hue, saturation, and brightness values
          # @param hue [DecimalType, QuantityType, Numeric] Hue component (0-360º)
          # @param saturation [PercentType, Numeric] Saturation component (0-100%)
          # @param brightness [PercentType, Numeric] Brightness component (0-100%)
          # @return [HSBType]
          def from_hsv(hue, saturation, brightness)
            new(hue, saturation, brightness)
          end

          # add additional "overloads" to the constructor
          # @!visibility private
          def new(*args) # rubocop:disable Metrics
            if args.length == 1 && args.first.respond_to?(:to_str)
              value = args.first.to_str

              # parse some formats OpenHAB doesn't understand
              # in this case, HTML hex format for rgb
              if (match = value.match(/^#(\h{2})(\h{2})(\h{2})$/))
                rgb = match.to_a[1..3].map { |v| v.to_i(16) }
                logger.trace("creating from rgb #{rgb.inspect}")
                return from_rgb(*rgb)
              end
            end

            # Convert strings using java class
            return value_of(args.first) if args.length == 1 && args.first.is_a?(String)

            # use super constructor for empty args
            return super unless args.length == 3

            # convert from several numeric-like types to the exact types
            # OpenHAB needs
            hue = args[0]
            args[0] = if hue.is_a?(DecimalType)
                        hue
                      elsif hue.is_a?(QuantityType)
                        DecimalType.new(hue.to_unit(org.openhab.core.library.unit.Units::DEGREE_ANGLE).to_big_decimal)
                      elsif hue.respond_to?(:to_d)
                        DecimalType.new(hue)
                      end
            args[1..2] = args[1..2].map do |v|
              if v.is_a?(PercentType)
                v
              elsif v.respond_to?(:to_d)
                PercentType.new(v)
              end
            end

            super(*args)
          end
        end

        #
        # Comparison
        #
        # @param [NumericType, Items::NumericItem, Items::ColorItem, Numeric, String]
        #   other object to compare to
        #
        # @return [Integer, nil] -1, 0, +1 depending on whether +other+ is
        #   less than, equal to, or greater than self
        #
        #   nil is returned if the two values are incomparable
        #
        def <=>(other)
          logger.trace("(#{self.class}) #{self} <=> #{other} (#{other.class})")
          if other.is_a?(Items::ColorItem) ||
             (other.is_a?(Items::GroupItem) && other.base_item.is_a?(ColorItem))
            return false unless other.state?

            self <=> other.state
          elsif other.respond_to?(:to_str)
            self <=> HSBType.new(other)
          else
            super
          end
        end

        #
        # Type Coercion
        #
        # Coerce object to a HSBType
        #
        # @param [NumericType, Items::NumericItem, Items::ColorItem, Numeric, String]
        #   other object to coerce to a HSBType
        #
        # @return [[HSBType, HSBType]]
        #
        def coerce(other)
          logger.trace("Coercing #{self} as a request from #{other.class}")
          if other.is_a?(Items::NumericItem) ||
             (other.is_a?(Items::GroupItem) && other.base_item.is_a?(Items::NumericItem))
            return unless other.state?

            [other.state, self]
          elsif other.respond_to?(:to_str)
            [HSBType.new(other.to_str), self]
          else
            super
          end
        end

        # rename raw methods so we can overwrite them
        # @!visibility private
        alias raw_hue hue

        # @!attribute [r] hue
        # @return [QuantityType]
        def hue
          QuantityType.new(raw_hue.to_big_decimal, org.openhab.core.library.unit.Units::DEGREE_ANGLE)
        end

        # Convert to a packed 32-bit RGB value representing the color in the default sRGB color model.
        #
        # The alpha component is always 100%.
        #
        # @return [Integer]
        alias argb rgb

        # Convert to a packed 24-bit RGB value representing the color in the default sRGB color model.
        # @return [Integer]
        def rgb
          argb & 0xffffff
        end

        # Convert to an HTML-style string of 6 hex characters in the default sRGB color model.
        # @return [String] +'#xxxxxx'+
        def to_hex
          Kernel.format('#%06x', rgb)
        end

        # include units
        # @!visibility private
        def to_s
          "#{hue},#{saturation},#{brightness}"
        end

        # @!attribute [r] saturation
        #   @return [PercentType]

        # @!attribute [r] brightness
        #   @return [PercentType]

        # @!attribute [r] red
        #   @return [PercentType]

        # @!attribute [r] green
        #   @return [PercentType]

        # @!attribute [r] blue
        #   @return [PercentType]

        # @!method to_rgb
        # Convert to RGB values representing the color in the default sRGB color model
        # @return [[PercentType, PercentType, PercentType]]

        # @!method to_xy
        #   Convert to the xyY values representing this object's color in CIE XY color model
        #   @return [[PercentType, PercentType]]
      end
    end
  end
end
