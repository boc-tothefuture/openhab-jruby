# frozen_string_literal: true

module OpenHAB
  module Core
    module Actions
      # @see CoreExt::Ephemeris
      class Ephemeris
        class << self
          #
          # Human readable name of the given holiday
          #
          # @param [Symbol, #holiday, nil] holiday
          # @return [String, nil]
          #
          # @example
          #   Ephemeris.holiday_name(Date.today) # => "Christmas"
          #   Ephemeris.holiday_name(:christmas) # => "Christmas"
          #
          def holiday_name(holiday)
            holiday = holiday.holiday if holiday.respond_to?(:holiday)
            return nil if holiday.nil?

            ::Ephemeris.get_holiday_description(to_holiday_property_key(holiday))
          end

          private

          def to_holiday_property_key(holiday)
            holiday = holiday.to_s
            return holiday.upcase unless holiday.include?(".")

            religion, holiday = holiday.split(/\.([^.]*)$/)
            :"#{religion}.#{holiday.upcase}"
          end
        end
      end
    end
  end
end
