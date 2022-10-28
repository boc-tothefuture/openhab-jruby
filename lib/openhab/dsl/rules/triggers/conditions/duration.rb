# frozen_string_literal: true

module OpenHAB
  module DSL
    module Rules
      module Triggers
        # @!visibility private
        module Conditions
          #
          # this is a no-op condition which simply executes the provided block
          #

          #
          # Struct capturing data necessary for a conditional trigger
          #
          # TriggerDelay = Struct.new(:to, :from, :duration, :timer, :tracking_to, keyword_init: true) do
          #  def timer_active?
          #    timer&.is_active
          #  end
          # end
          class Duration
            #
            # Create a new duration condition
            # @param [Object] to optional condition on to state
            # @param [Object] from optional condition on from state
            # @param [Duration] duration to state must stay at specific value before triggering
            #
            def initialize(to:, from:, duration:)
              to = Conditions::Proc.from_value(to)
              from = Conditions::Proc.from_value(from)
              @conditions = Conditions::Proc.new(to: to, from: from)
              @duration = duration
              @timer = nil
              logger.trace "Created Duration Condition To(#{to}) From(#{from}) "\
                           "Conditions(#{@conditions}) Duration(#{@duration})"
            end

            # Process rule
            # @param [Hash] inputs inputs from trigger
            #
            def process(mod:, inputs:, &block)
              process_trigger_delay(mod, inputs, &block)
            end

            # Cleanup any resources from the condition
            #
            # Cancels the timer, if it's active
            def cleanup
              @timer&.cancel
            end

            private

            #
            # Checks if there is an active timer
            # @return [true, false] true if the timer exists and is active, false otherwise
            def timer_active?
              @timer&.is_active
            end

            #
            # Check if trigger guards prevent rule execution
            #
            # @param [Map] inputs OpenHAB map object describing rule trigger
            #
            # @return [true,false] True if the rule should execute, false if trigger guard prevents execution
            #
            def check_trigger_guards(inputs)
              new_state, old_state = retrieve_states(inputs)
              @conditions.check_from(state: old_state) && @conditions.check_to(state: new_state)
            end

            #
            # Rerieve the newState and oldState, alternatively newStatus and oldStatus
            # from the input map
            #
            # @param [Map] inputs OpenHAB map object describing rule trigger
            #
            # @return [Array] An array of the values for [newState, oldState] or [newStatus, oldStatus]
            #
            def retrieve_states(inputs)
              new_state = inputs["newState"] || thing_status_to_sym(inputs["newStatus"])
              old_state = inputs["oldState"] || thing_status_to_sym(inputs["oldStatus"])

              [new_state, old_state]
            end

            #
            # Converts a ThingStatus object to a ruby Symbol
            #
            # @param [org.openhab.core.thing.ThingStatus] status A ThingStatus instance
            #
            # @return [Symbol] A corresponding symbol, in lower case
            #
            def thing_status_to_sym(status)
              status&.to_s&.downcase&.to_sym
            end

            #
            # Process any matching trigger delays
            #
            # @param [Map] mod OpenHAB map object describing rule trigger
            # @param [Map] inputs OpenHAB map object describing rule trigger
            #
            #
            def process_trigger_delay(mod, inputs, &block)
              if timer_active?
                process_active_timer(inputs, mod, &block)
              elsif check_trigger_guards(inputs)
                logger.trace("Trigger Guards Matched for #{self}, delaying rule execution")
                # Add timer and attach timer to delay object, and also state being tracked to so
                # timer can be cancelled if state changes
                # Also another timer should not be created if changed to same value again but instead rescheduled
                create_trigger_delay_timer(inputs, mod, &block)
              else
                logger.trace("Trigger Guards did not match for #{self}, ignoring trigger.")
              end
            end

            #
            # Creates a timer for trigger delays
            #
            # @param [Hash] inputs rule trigger inputs
            # @param [Hash] _mod rule trigger mods
            #
            #
            def create_trigger_delay_timer(inputs, _mod)
              logger.trace("Creating timer for trigger delay #{self}")
              @timer = DSL.after(@duration) do
                logger.trace("Delay Complete for #{self}, executing rule")
                @timer = nil
                yield
              end
              @tracking_to, = retrieve_states(inputs)
            end

            #
            # Process an active trigger timer
            #
            # @param [Hash] inputs rule trigger inputs
            # @param [Hash] mod rule trigger mods
            #
            #
            def process_active_timer(inputs, mod, &block)
              state, = retrieve_states(inputs)
              if state == @tracking_to
                logger.trace("Item changed to #{state} for #{self}, rescheduling timer.")
                @timer.reschedule(ZonedDateTime.now.plus(@duration))
              else
                logger.trace("Item changed to #{state} for #{self}, canceling timer.")
                @timer.cancel
                # Reprocess trigger delay after canceling to track new state (if guards matched, etc)
                process_trigger_delay(mod, inputs, &block)
              end
            end
          end
        end
      end
    end
  end
end
