# frozen_string_literal: true

module OpenHAB
  module Core
    module Rules
      # @interface
      java_import org.openhab.core.automation.Module

      # @!visibility private
      module Module
        # @return [String]
        def inspect
          r = "#<OpenHAB::Core::Rules::#{self.class.simple_name} #{id} (#{type_uid})"
          r += " #{label.inspect}" if label
          r += " configuration=#{configuration.properties.to_h}" unless configuration.properties.empty?
          "#{r}>"
        end

        # @return [String]
        def to_s
          id
        end
      end
    end
  end
end
