# frozen_string_literal: true

module OpenHAB
  module RSpec
    # ::RSpec::ExampleGroup extensions
    module ExampleGroup
      # Extensions for ::RSpec::ExampleGroup's singleton class.
      module ClassMethods
        # @!attribute [w] mock_timers
        #
        # Set if timers should be mocked for this example group.
        #
        # @param value [true, false, nil]
        # @return [true, false, nil]
        #
        # @example
        #   describe "my_rule" do
        #     self.mock_timers = false
        #
        #     it "runs a timer" do
        #       expect(self.class.mock_timers?).to be false
        #     end
        #   end
        #
        def mock_timers=(value)
          @mock_timers = value
        end

        #
        # If timers are mocked for this example group
        #
        # It will search through parent groups until it finds one where it's
        # explicitly defined, or defaults to `true` if none are.
        #
        # @return [true, false]
        def mock_timers?
          return @mock_timers if instance_variable_defined?(:@mock_timers) && !@mock_timers.nil?
          return superclass.mock_timers? if superclass.is_a?(ClassMethods)

          true
        end
      end

      # @!visibility private
      def self.included(klass)
        klass.singleton_class.include(ClassMethods)
      end
    end
  end
end
