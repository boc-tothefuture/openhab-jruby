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
        #
        def mock_timers?
          return @mock_timers if instance_variable_defined?(:@mock_timers) && !@mock_timers.nil?
          return superclass.mock_timers? if superclass.is_a?(ClassMethods)

          true
        end

        # @!attribute [w] consistent_proxies
        #
        # Set if Items and Thing proxies should return consistent objects.
        #
        # @param value [true, false, nil]
        # @return [true, false, nil]
        #
        # @example
        #   describe "my_rule" do
        #     self.consistent_proxies = false
        #
        #     it "does something" do
        #       expect(self.class.consistent_proxies?).to be false
        #     end
        #   end
        #
        # @see #consistent_proxies?
        #
        def consistent_proxies=(value)
          @consistent_proxies = value
        end

        #
        # If Item and Thing proxies will consistently return the same object.
        #
        # Useful for mocking and using the `be` matcher.
        #
        # It will search through parent groups until it finds one where it's
        # explicitly defined, or defaults to `true` if none are.
        #
        # @return [true, false]
        #
        def consistent_proxies?
          return @consistent_proxies if instance_variable_defined?(:@consistent_proxies) && !@consistent_proxies.nil?
          return superclass.consistent_proxies? if superclass.is_a?(ClassMethods)

          true
        end

        # @!attribute [w] propagate_exceptions
        #
        # Set if exceptions in rules should be propagated in specs, instead of just logged.
        #
        # @param value [true, false, nil]
        # @return [true, false, nil]
        #
        # @example
        #   describe "my_rule" do
        #     self.propagate_exceptions = false
        #
        #     it "logs exceptions in rule execution" do
        #       expect(self.class.propagate_exceptions?).to be false
        #       rule do
        #         on_load
        #         run { raise "exception is logged" }
        #       end
        #       expect(spec_log_lines).to include(match(/exception is logged/))
        #     end
        #   end
        #
        def propagate_exceptions=(value)
          @propagate_exceptions = value
        end

        #
        # If timers are mocked for this example group
        #
        # It will search through parent groups until it finds one where it's
        # explicitly defined, or defaults to `true` if none are.
        #
        # @return [true, false]
        #
        def propagate_exceptions?
          if instance_variable_defined?(:@propagate_exceptions) && !@propagate_exceptions.nil?
            return @propagate_exceptions
          end
          return superclass.propagate_exceptions? if superclass.is_a?(ClassMethods)

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
