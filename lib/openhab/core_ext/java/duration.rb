# frozen_string_literal: true

module OpenHAB
  module CoreExt
    module Java
      Duration = java.time.Duration

      # Extensions to Duration
      class Duration
        # @!parse include TemporalAmount

        alias_method :to_i, :seconds

        #
        # Convert to number of seconds
        #
        # @return [Float]
        #
        def to_f
          to_i + (nano / 1_000_000_000.0)
        end

        remove_method :==

        # @return [Integer, nil]
        def <=>(other)
          return to_f <=> other if other.is_a?(Numeric)

          super
        end

        #
        # Converts `other` to {Duration}, if possible.
        #
        # @param [Numeric, Period] other
        # @return [Array, nil]
        #
        def coerce(other)
          return [other.seconds, self] if other.is_a?(Numeric)
          return [other.to_i.seconds, self] if other.is_a?(Period)
        end

        {
          plus: :+,
          minus: :-
        }.each do |java_op, ruby_op|
          # def +(other)
          #   if other.is_a?(Duration)
          #     plus(other)
          #   elsif other.is_a?(Integer)
          #     plus_seconds(other)
          #   elsif other.is_a?(Numeric)
          #     plus(other.seconds)
          #   elsif other.respond_to?(:coerce) && (rhs, lhs = other.coerce(self))
          #     lhs + rhs
          #   else
          #     raise TypeError, "#{other.class} can't be coerced into Duration"
          #   end
          # end
          class_eval <<~RUBY, __FILE__, __LINE__ + 1 # rubocop:disable Style/DocumentDynamicEvalDefinition
            def #{ruby_op}(other)
              if other.is_a?(Duration)
                #{java_op}(other)
              elsif other.is_a?(Integer)
                #{java_op}_seconds(other)
              elsif other.is_a?(Numeric)
                #{java_op}(other.seconds)
              elsif other.respond_to?(:coerce) && (rhs, lhs = other.coerce(self))
                lhs #{ruby_op} rhs
              else
                raise TypeError, "\#{other.class} can't be coerced into Duration"
              end
            end
          RUBY
        end

        {
          multipliedBy: :*,
          dividedBy: :/
        }.each do |java_op, ruby_op|
          # def *(other)
          #   if other.is_a?(Integer)
          #     multipliedBy(other)
          #   elsif other.is_a?(Numeric)
          #     Duration.of_seconds(to_f * other)
          #   elsif other.is_a?(Duration)
          #     Duration.of_seconds(to_f * other.to_f)
          #   elsif other.respond_to?(:coerce) && (rhs, lhs = other.coerce(self))
          #     lhs * rhs
          #   else
          #     raise TypeError, "#{other.class} can't be coerced into Duration"
          #   end
          # end
          class_eval <<~RUBY, __FILE__, __LINE__ + 1 # rubocop:disable Style/DocumentDynamicEvalDefinition
            def #{ruby_op}(other)
              if other.is_a?(Integer)
                #{java_op}(other)
              elsif other.is_a?(Numeric)
                Duration.of_seconds(to_f #{ruby_op} other)
              elsif other.is_a?(Duration)
                Duration.of_seconds(to_f #{ruby_op} other.to_f)
              elsif other.respond_to?(:coerce) && (rhs, lhs = other.coerce(self))
                lhs #{ruby_op} rhs
              else
                raise TypeError, "\#{other.class} can't be coerced into Duration"
              end
            end
          RUBY
        end
      end
    end
  end
end
