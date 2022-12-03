# frozen_string_literal: true

require "forwardable"

require_relative "property"
require_relative "guard"
require_relative "rule_triggers"
require_relative "terse"

Dir[File.expand_path("triggers/*.rb", __dir__)].sort.each do |f|
  require f
end

module OpenHAB
  module DSL
    #
    # Creates and manages OpenHAB Rules
    #
    module Rules
      # A rules builder allows you to create OpenHAB rules.
      #
      # Note that all methods on this module are also availabe directly on {OpenHAB::DSL}.
      #
      class Builder
        include Terse
        include Core::EntityLookup

        self.create_dummy_items = true

        # @return [org.openhab.core.automation.RuleProvider]
        attr_reader :provider

        def initialize(provider)
          @provider = Core::Rules::Provider.current(provider)
        end

        #
        # Create a new rule
        #
        # The rule must have at least one trigger and one execution block.
        # To create a "script" without any triggers, use {#script}.
        #
        # @param [String] name The rule name
        # @yield Block executed in the context of a {Rules::BuilderDSL}
        # @yieldparam [Rules::BuilderDSL] rule
        #   Optional parameter to access the rule configuration from within execution blocks and guards.
        # @return [Core::Rules::Rule, nil] The rule object, or nil if no rule was created.
        #
        # @see OpenHAB::DSL::Rules::BuilderDSL Rule BuilderDSL for details on rule triggers, guards and execution blocks
        # @see Rules::Terse Terse Rules
        #
        # @example
        #   require "openhab/dsl"
        #
        #   rule "name" do
        #     <one or more triggers>
        #     <one or more execution blocks>
        #     <zero or more guards>
        #   end
        #
        def rule(name = nil, id: nil, script: nil, binding: nil, &block)
          raise ArgumentError, "Block is required" unless block

          id ||= NameInference.infer_rule_id_from_block(block)
          script ||= block.source rescue nil # rubocop:disable Style/RescueModifier

          builder = nil

          ThreadLocal.thread_local(openhab_rule_type: "rule", openhab_rule_uid: id) do
            builder = BuilderDSL.new(binding || block.binding)
            builder.uid(id)
            builder.instance_exec(builder, &block)
            builder.guard = Guard.new(run_context: builder.caller, only_if: builder.only_if,
                                      not_if: builder.not_if)

            name ||= NameInference.infer_rule_name(builder)
            name ||= id

            builder.name(name)
            logger.trace { builder.inspect }
            builder.build(provider, script)
          end
        end

        #
        # Create a new script
        #
        # A script is a rule with no triggers. It can be called by various other actions,
        # such as the Run Rules action.
        #
        # @param [String] name A descriptive name
        # @param [String] id The script's ID
        # @yield [] Block executed when the script is executed.
        # @return [Core::Rules::Rule]
        #
        def script(name = nil, id: nil, script: nil, &block)
          raise ArgumentError, "Block is required" unless block

          id ||= NameInference.infer_rule_id_from_block(block)
          name ||= id
          script ||= block.source rescue nil # rubocop:disable Style/RescueModifier

          builder = nil
          ThreadLocal.thread_local(openhab_rule_type: "script", openhab_rule_uid: id) do
            builder = BuilderDSL.new(block.binding)
            builder.uid(id)
            builder.tags(["Script"])
            builder.name(name)
            builder.script(&block)
            logger.trace { builder.inspect }
            builder.build(provider, script)
          end
        end
      end

      #
      # Rule configuration for OpenHAB Rules engine
      #
      class BuilderDSL
        include Core::EntityLookup
        include DSL
        prepend Triggers
        extend Property
        extend Forwardable

        self.create_dummy_items = true

        delegate %i[triggers trigger_conditions attachments] => :@rule_triggers

        # @!visibility private
        # @return [Array] Of trigger guards
        attr_accessor :guard

        # @!visibility private
        # @return [Object] object that invoked rule method
        attr_accessor :caller

        # @!visibility private
        # @return [Array] Of trigger definitions as passed in Ruby
        attr_reader :ruby_triggers

        # @!visibility private
        Run = Struct.new(:block)

        # @!visibility private
        Script = Struct.new(:block)

        # @!visibility private
        Trigger = Struct.new(:block)

        # @!visibility private
        Otherwise = Struct.new(:block)

        # @!visibility private
        Delay = Struct.new(:duration)

        # @!group Execution Blocks

        #
        # @!method run
        #
        # Add a block that will be passed event data.
        #
        # The run property is the automation code that is executed when a rule
        # is triggered. This property accepts a block of code and executes it.
        # The block is automatically passed an event object which can be used
        # to access multiple properties about the triggering event. The code
        # for the automation can be entirely within the run block and can call
        # methods defined in the Ruby script.
        #
        # @yieldparam [Core::Events::AbstractEvent] event
        # @return [void]
        #
        # @example `{}` style used for single line blocks.
        #   rule 'Access Event Properties' do
        #     changed TestSwitch
        #     run { |event| logger.info("#{event.item.name} triggered from #{event.was} to #{event.state}") }
        #   end
        #
        # @example `do/end` style used for multi-line blocks.
        #   rule 'Multi Line Run Block' do
        #     changed TestSwitch
        #     run do |event|
        #       logger.info("#{event.item.name} triggered")
        #       logger.info("from #{event.was}") if event.was?
        #       logger.info("to #{event.state}") if event.state?
        #      end
        #   end
        #
        # @example Rules can have multiple run blocks and they are executed in order. Useful when used in combination with {#delay}.
        #   rule 'Multiple Run Blocks' do
        #     changed TestSwitch
        #     run { |event| logger.info("#{event.item.name} triggered") }
        #     run { |event| logger.info("from #{event.was}") if event.was? }
        #     run { |event| logger.info("to #{event.state}") if event.state?  }
        #   end
        #
        prop_array :run, array_name: :run_queue, wrapper: Run

        prop_array :script, array_name: :run_queue, wrapper: Script

        #
        # @!method triggered
        #
        # Add a block that will be passed the triggering item.
        #
        # This property is the same as the {#run} property except rather than
        # passing an event object to the automation block the triggered item is
        # passed. This enables optimizations for simple cases and supports
        # Ruby's [pretzel colon `&:` operator.](https://medium.com/@dcjones/the-pretzel-colon-75df46dde0c7).
        #
        # @yieldparam [Item] item
        # @return [void]
        #
        # @example
        #   rule "motion sensor triggered" do
        #     changed MotionSensor.members, to: :OPEN
        #     triggered do |item|
        #       logger.info("#{item.name} detected motion")
        #     end
        #   end
        #
        # @example
        #   rule 'Triggered has access directly to item triggered' do
        #     changed TestSwitch
        #     triggered { |item| logger.info("#{item.name} triggered") }
        #   end
        #
        # @example Triggered items are highly useful when working with groups
        #   # Switches is a group of Switch items
        #   rule 'Triggered item is item changed when a group item is changed.' do
        #     changed Switches.members
        #     triggered { |item| logger.info("Switch #{item.name} changed to #{item.state}")}
        #   end
        #
        #   rule 'Turn off any switch that changes' do
        #     changed Switches.members
        #     triggered(&:off)
        #   end
        #
        # @example Like other execution blocks, multiple triggered blocks are supported in a single rule
        #   rule 'Turn a switch off and log it, 5 seconds after turning it on' do
        #     changed Switches.members, to: ON
        #     delay 5.seconds
        #     triggered(&:off)
        #     triggered {|item| logger.info("#{item.label} turned off") }
        #   end
        prop_array :triggered, array_name: :run_queue, wrapper: Trigger

        #
        # @!method delay(duration)
        #
        # Add a wait between or after run blocks.
        #
        # The delay property is a non thread-blocking element that is executed
        # after, before, or between run blocks.
        #
        # @param [java.time.temporal.TemporalAmount] duration How long to delay for.
        # @return [void]
        #
        # @example
        #   rule "delay execution" do
        #     changed MotionSensor, to: CLOSED
        #     delay 5.seconds
        #     run { Light.off }
        #   end
        #
        # @example
        #   rule 'Delay sleeps between execution elements' do
        #     on_start
        #     run { logger.info("Sleeping") }
        #     delay 5.seconds
        #     run { logger.info("Awake") }
        #   end
        #
        # @example Like other execution blocks, multiple can exist in a single rule.
        #   rule 'Multiple delays can exist in a rule' do
        #     on_start
        #     run { logger.info("Sleeping") }
        #     delay 5.seconds
        #     run { logger.info("Sleeping Again") }
        #     delay 5.seconds
        #     run { logger.info("Awake") }
        #   end
        #
        # @example You can use Ruby code in your rule across multiple execution blocks like a run and a delay.
        #   rule 'Dim a switch on system startup over 100 seconds' do
        #     on_start
        #     100.times do
        #       run { DimmerSwitch.dim }
        #       delay 1.second
        #     end
        #   end
        #
        prop_array :delay, array_name: :run_queue, wrapper: Delay

        #
        # @!method otherwise
        #
        # Add a block that will be passed event data, to be run if guards are
        # not satisfied.
        #
        # The {otherwise} property is the automation code that is executed when
        # a rule is triggered and guards are not satisfied.  This property
        # accepts a block of code and executes it. The block is automatically
        # passed an event object which can be used to access multiple
        # properties about the triggering event.
        #
        # @yieldparam [Core::Events::AbstractEvent] event
        #
        # @example
        #   rule 'Turn switch ON or OFF based on value of another switch' do
        #     on_start
        #     run { TestSwitch << ON }
        #     otherwise { TestSwitch << OFF }
        #     only_if { OtherSwitch.on? }
        #   end
        #
        prop_array :otherwise, array_name: :run_queue, wrapper: Otherwise

        # @!group Configuration

        #
        # @!method uid(id)
        #
        # Set the rule's UID.
        #
        # @param [String] id
        # @return [void]
        #
        prop :uid

        #
        # @!method name(value)
        #
        # Set the rule's name.
        #
        # @param [String] value
        # @return [void]
        #
        prop :name

        #
        # @!method description(value)
        #
        # Set the rule's description.
        #
        # @param [String] value
        # @return [void]
        #
        prop :description

        #
        # @!method tags(tags)
        #
        # Set the rule's tags.
        #
        # @param [String, Class, Array<String, Class>] tags
        # @return [void]
        #
        # @example
        #   rule "tagged rule" do
        #     tags "lighting", "security"
        #   end
        #
        prop :tags

        #
        # @!method enabled(value)
        #
        # Enable or disable the rule from executing
        #
        # @param [true,false] value
        # @return [void]
        #
        # @example
        #   rule "disabled rule" do
        #     enabled(false)
        #   end
        #
        prop :enabled

        # @!group Guards
        #   Guards exist to only permit rules to run if certain conditions are
        #   satisfied. Think of these as declarative `if` statements that keep
        #   the run block free of conditional logic, although you can of course
        #   still use conditional logic in run blocks if you prefer.
        #
        #   ### Guard Combination
        #
        #   {#only_if} and {#not_if} can be used on the same rule. Both must be
        #   satisfied for a rule to execute.
        #
        #   @example
        #     rule "Set OutsideDimmer to 50% if LightSwitch turned on and OtherSwitch is OFF and Door is CLOSED" do
        #       changed LightSwitch, to: ON
        #       run { OutsideDimmer << 50 }
        #       only_if { Door.closed? }
        #       not_if { OtherSwitch.on? }
        #     end
        #

        #
        # @!method between(range)
        #
        # Only execute rule if current time is between supplied time ranges.
        #
        # If the range is of strings, it will be parsed to an appropriate time class.
        #
        # @param [Range] range
        # @return [void]
        #
        # @example
        #   rule "Between guard" do
        #     changed MotionSensor, to: OPEN
        #     between "6:05".."14:05:05" # Include end
        #     run { Light.on }
        #   end
        #
        # @example
        #   rule "Between guard" do
        #     changed MotionSensor, to: OPEN
        #     between "6:05".."14:05:05" # Excludes end second
        #     run { Light.on }
        #   end
        #
        # @example
        #   rule "Between guard" do
        #     changed MotionSensor, to: OPEN
        #     between LocalTime.of(6, 5)..LocalTime.of(14, 15, 5)
        #     run { Light.on }
        #   end
        #
        # @example String of {LocalTime}
        #   rule 'Log an entry if started between 3:30:04 and midnight using strings' do
        #     on_start
        #     run { logger.info ("Started at #{LocalTime.now}")}
        #     between '3:30:04'..LocalTime::MIDNIGHT
        #   end
        #
        # @example {LocalTime}
        #   rule 'Log an entry if started between 3:30:04 and midnight using LocalTime objects' do
        #     on_start
        #     run { logger.info ("Started at #{LocalTime.now}")}
        #     between LocalTime.of(3, 30, 4)..LocalTime::MIDNIGHT
        #   end
        #
        # @example String of {MonthDay}
        #   rule 'Log an entry if started between March 9th and April 10ths' do
        #     on_start
        #     run { logger.info ("Started at #{Time.now}")}
        #     between '03-09'..'04-10'
        #   end
        #
        # @example {MonthDay}
        #   rule 'Log an entry if started between March 9th and April 10ths' do
        #     on_start
        #     run { logger.info ("Started at #{Time.now}")}
        #     between MonthDay.of(03,09)..'04-06'
        #   end
        #
        prop :between

        #
        # @!method only_if
        #
        # {only_if} allows rule execution when the block's is true and prevents it when it's false.
        #
        # @yieldparam [Core::Events::AbstractEvent] event The event data that is about to trigger the rule.
        # @yieldreturn [Boolean] A value indicating if the rule should run.
        # @return [void]
        #
        # @example
        #   rule "Set OutsideDimmer to 50% if LightSwitch turned on and OtherSwitch is also ON" do
        #     changed LightSwitch, to: ON
        #     run { OutsideDimmer << 50 }
        #     only_if { OtherSwitch.on? }
        #   end
        #
        # @example Multiple {only_if} statements can be used and *all* must be true for the rule to run.
        #   rule "Set OutsideDimmer to 50% if LightSwitch turned on and OtherSwitch is also ON and Door is closed" do
        #     changed LightSwitch, to: ON
        #     run { OutsideDimmer << 50 }
        #     only_if { OtherSwitch.on? }
        #     only_if { Door.closed? }
        #   end
        #
        # @example Guards have access to event information.
        #   rule "Set OutsideDimmer to 50% if any switch in group Switches starting with Outside is switched On" do
        #     changed Switches.items, to: ON
        #     run { OutsideDimmer << 50 }
        #     only_if { |event| event.item.name.start_with?("Outside") }
        #   end
        #
        prop_array(:only_if) do |item|
          unless item.is_a?(Proc) || [item].flatten.all? { |it| it.respond_to?(:truthy?) }
            raise ArgumentError, "Object passed to only_if must be a proc"
          end
        end

        #
        # @!method not_if
        #
        # {not_if} prevents execution of rules when the block's result is true and allows it when it's true.
        #
        # @yieldparam [Core::Events::AbstractEvent] event The event data that is about to trigger the rule.
        # @yieldreturn [Boolean] A value indicating if the rule should _not_ run.
        # @return [void]
        #
        # @example
        #   rule "Set OutsideDimmer to 50% if LightSwtich turned on and OtherSwitch is OFF" do
        #     changed LightSwitch, to: ON
        #     run { OutsideDimmer << 50 }
        #     not_if { OtherSwitch.on? }
        #   end
        #
        # @example Multiple {not_if} statements can be used and if **any** of them are not satisfied the rule will not run.
        #   rule "Set OutsideDimmer to 50% if LightSwitch turned on and OtherSwitch is OFF and Door is not CLOSED" do
        #     changed LightSwitch, to: ON
        #     run { OutsideDimmer << 50 }
        #     not_if { OtherSwitch.on? }
        #     not_if { Door.closed? }
        #   end
        #
        prop_array(:not_if) do |item|
          unless item.is_a?(Proc) || [item].flatten.all? { |it| it.respond_to?(:truthy?) }
            raise ArgumentError, "Object passed to not_if must be a proc"
          end
        end

        # @!endgroup

        # @!visibility private
        #
        # Create a new DSL
        #
        # @param [Object] caller_binding The object initializing this configuration.
        #   Used to execute within the object's context
        #
        def initialize(caller_binding)
          @rule_triggers = RuleTriggers.new
          @caller = caller_binding.eval "self"
          @ruby_triggers = []
          enabled(true)
          on_start(false)
          tags([])
        end

        # @!group Triggers
        #   Triggers specify what will cause the execution blocks to run.
        #   Multiple triggers can be defined within the same rule.
        #
        #   ### Trigger Attachments
        #
        #   All triggers support event attachments that enable the association
        #   of an object to a trigger. This enables one to use the same rule
        #   and take different actions if the trigger is different. The
        #   attached object is passed to the execution block through the
        #   {Core::Events::AbstractEvent#attachment} accessor.
        #
        #   @note The trigger attachment feature is not available for UI rules.
        #
        #   @example
        #     rule 'Set Dark switch at sunrise and sunset' do
        #       channel 'astro:sun:home:rise#event', attach: OFF
        #       channel 'astro:sun:home:set#event', attach: ON
        #       run { |event| Dark << event.attachment }
        #     end

        #
        # Creates a channel trigger
        #
        # The channel trigger executes rule when a specific channel is triggered. The syntax
        # supports one or more channels with one or more triggers. `thing` is an optional
        # parameter that makes it easier to set triggers on multiple channels on the same thing.
        #
        # @param [String, Core::Things::Channel, Core::Things::ChannelUID] channels
        #   channels to create triggers for in form of 'binding_id:type_id:thing_id#channel_id'
        #   or 'channel_id' if thing is provided.
        # @param [String, Core::Things::Thing, Core::Things::ThingUID] thing
        #   Thing(s) to create trigger for if not specified with the channel.
        # @param [String, Array<String>] triggered
        #   Only execute rule if the event on the channel matches this/these event/events.
        # @param [Object] attach object to be attached to the trigger
        # @return [void]
        #
        # @example
        #   rule "Execute rule when channel is triggered" do
        #     channel "astro:sun:home:rise#event"
        #     run { logger.info("Channel triggered") }
        #   end
        #   # The above is the same as each of the below
        #
        #   rule "Execute rule when channel is triggered" do
        #     channel "rise#event", thing: "astro:sun:home"
        #     run { logger.info("Channel triggered") }
        #   end
        #
        #   rule "Execute rule when channel is triggered" do
        #     channel "rise#event", thing: things["astro:sun:home"]
        #     run { logger.info("Channel triggered") }
        #   end
        #
        #   rule "Execute rule when channel is triggered" do
        #     channel "rise#event", thing: things["astro:sun:home"].uid
        #     run { logger.info("Channel triggered") }
        #   end
        #
        #   rule "Execute rule when channel is triggered" do
        #     channel "rise#event", thing: ["astro:sun:home"]
        #     run { logger.info("Channel triggered") }
        #   end
        #
        #   rule "Execute rule when channel is triggered" do
        #     channel things["astro:sun:home"].channels["rise#event"]
        #     run { logger.info("Channel triggered") }
        #   end
        #
        #   rule "Execute rule when channel is triggered" do
        #     channel things["astro:sun:home"].channels["rise#event"].uid
        #     run { logger.info("Channel triggered") }
        #   end
        #
        # @example
        #   rule "Rule provides access to channel trigger events in run block" do
        #     channel "astro:sun:home:rise#event", triggered: 'START'
        #     run { |trigger| logger.info("Channel(#{trigger.channel}) triggered event: #{trigger.event}") }
        #   end
        #
        # @example
        #   rule "Keypad Code Received test" do
        #     channel "mqtt:homie300:mosquitto:backgate:keypad#code"
        #     run do |event|
        #       logger.info("Received keycode from #{event.channel.thing.uid.id}")
        #     end
        #   end
        #
        # @example
        #   rule "Rules support multiple channels" do
        #     channel "rise#event", "set#event", thing: "astro:sun:home"
        #     run { logger.info("Channel triggered") }
        #   end
        #
        # @example
        #   rule "Rules support multiple channels and triggers" do
        #     channel "rise#event", "set#event", thing: "astro:sun:home", triggered: ["START", "STOP"]
        #     run { logger.info("Channel triggered") }
        #   end
        #
        # @example
        #   rule "Rules support multiple things" do
        #     channel "keypad#code", thing: ["mqtt:homie300:keypad1", "mqtt:homie300:keypad2"]
        #     run { logger.info("Channel triggered") }
        #   end
        #
        def channel(*channels, thing: nil, triggered: nil, attach: nil)
          channel_trigger = Channel.new(rule_triggers: @rule_triggers)
          flattened_channels = Channel.channels(channels: channels, thing: thing)
          triggers = [triggered].flatten
          @ruby_triggers << [:channel, flattened_channels, { triggers: triggers }]
          flattened_channels.each do |channel|
            triggers.each do |trigger|
              channel_trigger.trigger(channel: channel, trigger: trigger, attach: attach)
            end
          end
        end

        #
        # Creates a channel linked trigger
        #
        # @param [Object] attach object to be attached to the trigger
        # @return [void]
        #
        # @example
        #    rule "channel linked" do
        #      channel_linked
        #      run do |event|
        #        logger.info("#{event.link.item.name} linked to #{event.link.channel_uid}.")
        #      end
        #    end
        def channel_linked(attach: nil)
          @ruby_triggers << [:channel_linked]
          trigger("core.GenericEventTrigger", eventTopic: "openhab/links/*/added",
                                              eventTypes: "ItemChannelLinkAddedEvent", attach: attach)
        end

        #
        # Creates a channel unlinked trigger
        #
        # Note that the item or the thing it's linked to may no longer exist,
        # so if you try to access those objects they'll be nil.
        #
        # @param [Object] attach object to be attached to the trigger
        # @return [void]
        #
        # @example
        #    rule "channel unlinked" do
        #      channel_unlinked
        #      run do |event|
        #        logger.info("#{event.link.item_name} unlinked from #{event.link.channel_uid}.")
        #      end
        #    end
        def channel_unlinked(attach: nil)
          @ruby_triggers << [:channel_linked]
          trigger("core.GenericEventTrigger", eventTopic: "openhab/links/*/removed",
                                              eventTypes: "ItemChannelLinkRemovedEvent", attach: attach)
        end

        #
        # Creates a trigger when an item, member of a group, or a thing changed
        # states.
        #
        # When the changed element is a {Core::Things::Thing Thing}, the `from`
        # and `to` values will accept symbols and strings, where the symbol'
        # matches the
        # [supported status](https://www.openhab.org/docs/concepts/things.html#thing-status).
        #
        # The `event` passed to run blocks will be an
        # {Core::Events::ItemStateChangedEvent} or a
        # {Core::Events::ThingStatusInfoChangedEvent} depending on if the
        # triggering element was an item or a thing.
        #
        # @param [Item, GroupItem::Members, Thing] items Objects to create trigger for.
        # @param [State, Array<State>, Range, Proc] from
        #   Only execute rule if previous state matches `from` state(s).
        # @param [State, Array<State>, Range, Proc] to State(s) for
        #   Only execute rule if new state matches `to` state(s).
        # @param [java.time.temporal.TemporalAmount] for
        #   Duration item must remain in the same state before executing the execution blocks.
        # @param [Object] attach object to be attached to the trigger
        # @return [void]
        #
        # @example Multiple items can be separated with a comma:
        #   rule "Execute rule when either sensor changed" do
        #     changed FrontMotion_Sensor, RearMotion_Sensor
        #     run { |event| logger.info("Motion detected by #{event.item.name}") }
        #   end
        #
        # @example Group member trigger
        #   rule "Execute rule when member changed" do
        #     changed Sensors.members
        #     run { |event| logger.info("Motion detected by #{event.item.name}") }
        #   end
        #
        # @example `for` parameter can be a proc too:
        #   Alarm_Delay << 20
        #
        #   rule "Execute rule when item is changed for specified duration" do
        #     changed Alarm_Mode, for: -> { Alarm_Delay.state }
        #     run { logger.info("Alarm Mode Updated") }
        #   end
        #
        # @example You can optionally provide `from` and `to` states to restrict the cases in which the rule executes:
        #   rule "Execute rule when item is changed to specific number, from specific number, for specified duration" do
        #     changed Alarm_Mode, from: 8, to: [14,12], for: 12.seconds
        #     run { logger.info("Alarm Mode Updated") }
        #   end
        #
        # @example Works with ranges:
        #   rule "Execute when item changed to a range of numbers, from a range of numbers, for specified duration" do
        #     changed Alarm_Mode, from: 8..10, to: 12..14, for: 12.seconds
        #     run { logger.info("Alarm Mode Updated") }
        #   end
        #
        # @example Works with endless ranges:
        #   rule "Execute rule when item is changed to any number greater than 12"
        #     changed Alarm_Mode, to: (12..)   # Parenthesis required for endless ranges
        #     run { logger.info("Alarm Mode Updated") }
        #   end
        #
        # @example Works with procs:
        #   rule "Execute when item state is changed from an odd number, to an even number, for specified duration" do
        #     changed Alarm_Mode, from: proc { |from| from.odd? }, to: proc {|to| to.even? }, for: 12.seconds
        #     run { logger.info("Alarm Mode Updated") }
        #   end
        #
        # @example Works with lambdas:
        #   rule "Execute when item state is changed from an odd number, to an even number, for specified duration" do
        #     changed Alarm_Mode, from: -> from { from.odd? }, to: -> to { to.even? }, for: 12.seconds
        #     run { logger.info("Alarm Mode Updated") }
        #   end
        #
        # @example Works with Things:
        #   rule "Execute rule when thing is changed" do
        #     changed things["astro:sun:home"], :from => :online, :to => :uninitialized
        #     run { |event| logger.info("Thing #{event.uid} status <trigger> to #{event.status}") }
        #   end
        #
        # @example Real World Example
        #   rule "Log (or notify) when an exterior door is left open for more than 5 minutes" do
        #     changed ExteriorDoors.members, to: OPEN, for: 5.minutes
        #     triggered {|door| logger.info("#{door.name} has been left open!") }
        #   end
        #
        def changed(*items, to: nil, from: nil, for: nil, attach: nil)
          changed = Changed.new(rule_triggers: @rule_triggers)
          # for is a reserved word in ruby, so use local_variable_get :for
          duration = binding.local_variable_get(:for)

          from = [nil] if from.nil?
          to = [nil] if to.nil?

          @ruby_triggers << [:changed, items, { to: to, from: from, duration: duration }]
          items.each do |item|
            case item
            when Core::Things::Thing,
                 Core::Things::ThingUID,
                 Core::Items::Item,
                 Core::Items::GroupItem::Members
              nil
            else
              raise ArgumentError, "items must be an Item, GroupItem::Members, Thing, or ThingUID"
            end

            logger.trace("Creating changed trigger for entity(#{item}), to(#{to.inspect}), from(#{from.inspect})")

            Array.wrap(from).each do |from_state|
              Array.wrap(to).each do |to_state|
                changed.trigger(item: item, from: from_state, to: to_state, duration: duration, attach: attach)
              end
            end
          end
        end

        #
        # Create a cron trigger
        #
        # @overload cron(expression, attach: nil)
        #   @param [String, nil] expression [OpenHAB style cron expression](https://www.openhab.org/docs/configuration/rules-dsl.html#time-based-triggers)
        #   @param [Object] attach object to be attached to the trigger
        #
        #   @example Using a cron expression
        #     rule "cron expression" do
        #       cron "43 46 13 ? * ?"
        #       run { Light.on }
        #     end
        #
        # @overload cron(second: nil, minute: nil, hour: nil, dom: nil, month: nil, dow: nil, year: nil, attach: nil)
        #   The trigger can be created by specifying each field as keyword arguments.
        #   Omitted fields will default to `*` or `?` as appropriate.
        #
        #   Each field is optional, but at least one must be specified.
        #
        #   The same rules for the standard
        #   [cron expression](https://www.quartz-scheduler.org/documentation/quartz-2.2.2/tutorials/tutorial-lesson-06.html)
        #   apply for each field. For example, multiple values can be separated
        #   with a comma within a string.
        #
        #   @param [Integer, String, nil] second
        #   @param [Integer, String, nil] minute
        #   @param [Integer, String, nil] hour
        #   @param [Integer, String, nil] dom
        #   @param [Integer, String, nil] month
        #   @param [Integer, String, nil] dow
        #   @param [Integer, String, nil] year
        #   @param [Object] attach object to be attached to the trigger
        #   @example
        #     # Run every 3 minutes on Monday to Friday
        #     # equivalent to the cron expression "0 */3 * ? * MON-FRI *"
        #     rule "Using cron fields" do
        #       cron second: 0, minute: "*/3", dow: "MON-FRI"
        #       run { logger.info "Cron rule executed" }
        #     end
        #
        # @return [void]
        #
        def cron(expression = nil, attach: nil, **fields)
          if fields.any?
            raise ArgumentError, "Cron elements cannot be used with a cron expression" if expression

            cron_expression = Cron.from_fields(fields)
            return cron(cron_expression, attach: attach)
          end

          raise ArgumentError, "Missing cron expression or elements" unless expression

          cron = Cron.new(rule_triggers: @rule_triggers)
          cron.trigger(config: { "cronExpression" => expression }, attach: attach)
        end

        #
        # Create a rule that executes at the specified interval.
        #
        # @param [String,
        #   Duration,
        #   java.time.MonthDay,
        #   :second,
        #   :minute,
        #   :hour,
        #   :day,
        #   :week,
        #   :month,
        #   :year,
        #   :monday,
        #   :tuesday,
        #   :wednesday,
        #   :thursday,
        #   :friday,
        #   :saturday,
        #   :sunday] value
        #   When to execute rule.
        # @param [LocalTime, String, nil] at What time of day to execute rule
        # @param [Object] attach Object to be attached to the trigger
        # @return [void]
        #
        # @example
        #   rule "Daily" do
        #     every :day, at: '5:15'
        #     run do
        #       Light.on
        #     end
        #   end
        #
        # @example The above rule could also be expressed using LocalTime class as below
        #   rule "Daily" do
        #     every :day, at: LocalTime.of(5, 15)
        #     run { Light.on }
        #   end
        #
        # @example
        #   rule "Weekly" do
        #     every :monday, at: '5:15'
        #     run do
        #       Light.on
        #     end
        #   end
        #
        # @example
        #   rule "Often" do
        #     every :minute
        #     run do
        #       Light.on
        #     end
        #   end
        #
        # @example
        #   rule "Hourly" do
        #     every :hour
        #     run do
        #       Light.on
        #     end
        #   end
        #
        # @example
        #   rule "Often" do
        #     every 5.minutes
        #     run do
        #       Light.on
        #     end
        #   end
        #
        # @example
        #   rule 'Every 14th of Feb at 2pm' do
        #     every '02-14', at: '2pm'
        #     run { logger.info "Happy Valentine's Day!" }
        #   end
        #
        def every(value, at: nil, attach: nil)
          return every(java.time.MonthDay.parse(value), at: at, attach: attach) if value.is_a?(String)

          @ruby_triggers << [:every, value, { at: at }]

          cron_expression = case value
                            when Symbol then Cron.from_symbol(value, at)
                            when Duration then Cron.from_duration(value, at)
                            when java.time.MonthDay then Cron.from_monthday(value, at)
                            else raise ArgumentError, "Unknown interval"
                            end
          cron(cron_expression, attach: attach)
        end

        #
        # Run this rule when the script is loaded.
        #
        # Execute the rule on OpenHAB start up and whenever the script is
        # reloaded. This is useful to perform initialization routines,
        # especially when combined with other triggers.
        #
        # @param [true, false] run_on_start Run this rule on start, defaults to True
        # @param [Object] attach object to be attached to the trigger
        # @return [void]
        #
        # @example
        #   rule "startup rule" do
        #     on_start
        #     run do
        #       <calculate some item state>
        #     end
        #   end
        #
        # @example
        #   rule 'Ensure all security lights are on' do
        #     on_start
        #     run { Security_Lights.on }
        #   end
        #
        # rubocop:disable Style/OptionalBooleanParameter
        def on_start(run_on_start = true, attach: nil)
          @on_start = Struct.new(:enabled, :attach).new(run_on_start, attach)
        end
        # rubocop:enable Style/OptionalBooleanParameter

        #
        # Create a trigger for when an item or group receives a command
        #
        # The command/commands parameters are replicated for DSL fluency.
        #
        # The `event` passed to run blocks will be an
        # {Core::Events::ItemCommandEvent}.
        #
        # @param [Item, GroupItem::Members] items Items to create trigger for
        # @param [Core::TypesCommand, Array<Command>, Range, Proc] command commands to match for trigger
        # @param [Array<Command>, Range, Proc] commands Fluent alias for `command`
        # @param [Object] attach object to be attached to the trigger
        # @return [void]
        #
        # @example
        #   rule 'Execute rule when item received command' do
        #     received_command Alarm_Mode
        #     run { |event| logger.info("Item received command: #{event.command}" ) }
        #   end
        #
        # @example
        #   rule 'Execute rule when item receives specific command' do
        #     received_command Alarm_Mode, command: 7
        #     run { |event| logger.info("Item received command: #{event.command}" ) }
        #   end
        #
        # @example
        #   rule 'Execute rule when item receives one of many specific commands' do
        #     received_command Alarm_Mode, commands: [7,14]
        #     run { |event| logger.info("Item received command: #{event.command}" ) }
        #   end
        #
        # @example
        #   rule 'Execute rule when group receives a specific command' do
        #     received_command AlarmModes
        #     triggered { |item| logger.info("Group #{item.name} received command")}
        #   end
        #
        # @example
        #   rule 'Execute rule when member of group receives any command' do
        #     received_command AlarmModes.members
        #     triggered { |item| logger.info("Group item #{item.name} received command")}
        #   end
        #
        # @example
        #   rule 'Execute rule when member of group is changed to one of many states' do
        #     received_command AlarmModes.members, commands: [7, 14]
        #     triggered { |item| logger.info("Group item #{item.name} received command")}
        #   end
        #
        # @example
        #   rule 'Execute rule when item receives a range of commands' do
        #     received_command Alarm_Mode, commands: 7..14
        #     run { |event| logger.info("Item received command: #{event.command}" ) }
        #   end
        #
        # @example Works with procs
        #   rule 'Execute rule when Alarm Mode command is odd' do
        #     received_command Alarm_Mode, command: proc { |c| c.odd? }
        #     run { |event| logger.info("Item received command: #{event.command}" ) }
        #   end
        #
        # @example Works with lambdas
        #   rule 'Execute rule when Alarm Mode command is odd' do
        #     received_command Alarm_Mode, command: -> c { c.odd? }
        #     run { |event| logger.info("Item received command: #{event.command}" ) }
        #   end
        #
        def received_command(*items, command: nil, commands: nil, attach: nil)
          command_trigger = Command.new(rule_triggers: @rule_triggers)

          # if neither command nor commands is specified, ensure that we create
          # a trigger that isn't looking for a specific command.
          commands = [nil] if command.nil? && commands.nil?
          commands = Array.wrap(command) | Array.wrap(commands)

          @ruby_triggers << [:received_command, items, { command: commands }]

          items.each do |item|
            case item
            when Core::Items::Item,
                 Core::Items::GroupItem::Members
              nil
            else
              raise ArgumentError, "items must be an Item or GroupItem::Members"
            end
            commands.each do |cmd|
              logger.trace "Creating received command trigger for items #{item.inspect} and commands #{cmd.inspect}"

              command_trigger.trigger(item: item, command: cmd, attach: attach)
            end
          end
        end

        #
        # Creates a thing added trigger
        #
        # @param [Object] attach object to be attached to the trigger
        # @return [void]
        #
        # @example
        #    rule "thing added" do
        #      thing_added
        #      run do |event|
        #        logger.info("#{event.thing.uid} added.")
        #      end
        #    end
        def thing_added(attach: nil)
          @ruby_triggers << [:thing_added]
          trigger("core.GenericEventTrigger", eventTopic: "openhab/things/*/added",
                                              eventTypes: "ThingAddedEvent", attach: attach)
        end

        #
        # Creates a thing removed trigger
        #
        # @param [Object] attach object to be attached to the trigger
        # @return [void]
        #
        # @example
        #    rule "thing removed" do
        #      thing_removed
        #      run do |event|
        #        logger.info("#{event.thing.uid} removed.")
        #      end
        #    end
        def thing_removed(attach: nil)
          @ruby_triggers << [:thing_removed]
          trigger("core.GenericEventTrigger", eventTopic: "openhab/things/*/removed",
                                              eventTypes: "ThingRemovedEvent", attach: attach)
        end

        #
        # Creates a thing updated trigger
        #
        # @param [Object] attach object to be attached to the trigger
        # @return [void]
        #
        # @example
        #    rule "thing updated" do
        #      thing_updated
        #      run do |event|
        #        logger.info("#{event.thing.uid} updated.")
        #      end
        #    end
        #
        def thing_updated(attach: nil)
          @ruby_triggers << [:thing_removed]
          trigger("core.GenericEventTrigger", eventTopic: "openhab/things/*/updated",
                                              eventTypes: "ThingUpdatedEvent", attach: attach)
        end

        #
        # Create a generic trigger given the trigger type uid and a configuration hash
        #
        # This provides the ability to create a trigger type not already covered by the other methods.
        #
        # @param [String] type Trigger type UID
        # @param [Object] attach object to be attached to the trigger
        # @param [Hash] configuration A hash containing the trigger configuration entries
        # @return [void]
        #
        # @example Create a trigger for the [PID Controller Automation](https://www.openhab.org/addons/automation/pidcontroller/) add-on.
        #   rule 'PID Control' do
        #     trigger 'pidcontroller.trigger',
        #       input: InputItem.name,
        #       setpoint: SetPointItem.name,
        #       kp: 10,
        #       ki: 10,
        #       kd: 10,
        #       kdTimeConstant: 1,
        #       loopTime: 1000
        #
        #     run do |event|
        #       logger.info("PID controller command: #{event.command}")
        #       ControlItem << event.command
        #     end
        #   end
        #
        # @example DateTime Trigger
        #   rule 'DateTime Trigger' do
        #     description 'Triggers at a time specified in MyDateTimeItem'
        #     trigger 'timer.DateTimeTrigger', itemName: MyDateTimeItem.name
        #     run do
        #       logger.info("DateTimeTrigger has been triggered")
        #     end
        #   end
        #
        def trigger(type, attach: nil, **configuration)
          logger.trace("Creating a generic trigger for type(#{type}) with configuration(#{configuration})")
          Triggers::Trigger.new(rule_triggers: @rule_triggers)
                           .append_trigger(type: type, config: configuration, attach: attach)
        end

        #
        # Create a trigger when item, group or thing is updated
        #
        # The `event` passed to run blocks will be an
        # {Core::Events::ItemStateEvent} or a
        # {Core::Events::ThingStatusInfoEvent} depending on if the triggering
        # element was an item or a thing.
        #
        # @param [Item, GroupItem::Members, Thing] items
        #   Objects to create trigger for.
        # @param [State, Array<State>, Range, Proc, Symbol, String] to
        #   Only execute rule if the state matches `to` state(s). If the
        #   updated element is a {Core::Things::Thing}, the `to` accepts
        #   symbols and strings that match
        #   [supported thing statuses](https://www.openhab.org/docs/concepts/things.html#thing-status).
        # @param [Object] attach object to be attached to the trigger
        # @return [void]
        #
        # @example
        #   rule 'Execute rule when item is updated to any value' do
        #     updated Alarm_Mode
        #     run { logger.info("Alarm Mode Updated") }
        #   end
        #
        # @example
        #   rule 'Execute rule when item is updated to specific number' do
        #     updated Alarm_Mode, to: 7
        #     run { logger.info("Alarm Mode Updated") }
        #   end
        #
        # @example
        #   rule 'Execute rule when item is updated to one of many specific states' do
        #     updated Alarm_Mode, to: [7, 14]
        #     run { logger.info("Alarm Mode Updated")}
        #   end
        #
        # @example
        #   rule 'Execute rule when item is within a range' do
        #     updated Alarm_Mode, to: 7..14
        #     run { logger.info("Alarm Mode Updated to a value between 7 and 14")}
        #   end
        #
        # @example
        #   rule 'Execute rule when group is updated to any state' do
        #     updated AlarmModes
        #     triggered { |item| logger.info("Group #{item.name} updated")}
        #   end
        #
        # @example
        #   rule 'Execute rule when member of group is changed to any state' do
        #     updated AlarmModes.members
        #     triggered { |item| logger.info("Group item #{item.name} updated")}
        #   end
        #
        # @example
        #   rule 'Execute rule when member of group is changed to one of many states' do
        #     updated AlarmModes.members, to: [7, 14]
        #     triggered { |item| logger.info("Group item #{item.name} updated")}
        #   end
        #
        # @example Works with procs
        #   rule 'Execute rule when member of group is changed to an odd state' do
        #     updated AlarmModes.members, to: proc { |t| t.odd? }
        #     triggered { |item| logger.info("Group item #{item.name} updated")}
        #   end
        #
        # @example Works with lambdas:
        #   rule 'Execute rule when member of group is changed to an odd state' do
        #     updated AlarmModes.members, to: -> t { t.odd? }
        #     triggered { |item| logger.info("Group item #{item.name} updated")}
        #   end
        #
        # @example Works with things as well
        #   rule 'Execute rule when thing is updated' do
        #      updated things['astro:sun:home'], :to => :uninitialized
        #      run { |event| logger.info("Thing #{event.uid} status <trigger> to #{event.status}") }
        #   end
        #
        def updated(*items, to: nil, attach: nil)
          updated = Updated.new(rule_triggers: @rule_triggers)
          @ruby_triggers << [:updated, items, { to: to }]
          items.map do |item|
            case item
            when Core::Things::Thing,
                 Core::Things::ThingUID,
                 Core::Items::Item,
                 Core::Items::GroupItem::Members
              nil
            else
              raise ArgumentError, "items must be an Item, GroupItem::Members, Thing, or ThingUID"
            end

            logger.trace("Creating updated trigger for item(#{item}) to(#{to})")
            [to].flatten.map do |to_state|
              updated.trigger(item: item, to: to_state, attach: attach)
            end
          end.flatten
        end

        #
        # Create a trigger to watch a path
        #
        # It provides the ability to create a trigger on file and directory
        # changes.
        #
        # If a file or a path that does not exist is supplied as the argument
        # to watch, the parent directory will be watched and the file or
        # non-existent part of the supplied path will become the glob. For
        # example, if the directory given is `/tmp/foo/bar` and `/tmp/foo`
        # exists but `bar` does not exist inside of of `/tmp/foo` then the
        # directory `/tmp/foo` will be watched for any files that match
        # `*/bar`.
        #
        # If the last part of the path contains any glob characters e.g.
        # `/tmp/foo/*bar`, the parent directory will be watched and the last
        # part of the path will be treated as if it was passed as the `glob`
        # argument. In other words, `watch '/tmp/foo/*bar'` is equivalent to
        # `watch '/tmp/foo', glob: '*bar'`
        #
        # The `event` passed to run blocks will be a {Events::WatchEvent}.
        #
        # @param [String] path Path to watch. Can be a directory of a file.
        # @param [String] glob
        #   Limit events to paths matching this glob. Globs are matched using
        #   [File.fnmatch?](https://ruby-doc.org/core-2.6/File.html#method-c-fnmatch-3F)
        #   rules.
        # @param [Array<:created, :deleted, :modified>, :created, :deleted, :modified] for
        #   Types of changes to watch for.
        # @param [Object] attach object to be attached to the trigger
        # @return [void]
        #
        # @example Watch `items` directory inside of the OpenHAB configuration path and log any changes.
        #   rule 'watch directory' do
        #     watch OpenHAB::Core.config_folder / 'items'
        #     run { |event| logger.info("#{event.path.basename} - #{event.type}") }
        #   end
        #
        # @example Watch `items` directory for files that end in `*.erb` and log any changes
        #   rule 'watch directory' do
        #     watch OpenHAB::Core.config_folder / 'items', glob: '*.erb'
        #     run { |event| logger.info("#{event.path.basename} - #{event.type}") }
        #   end
        #
        # @example Watch `items/foo.items` log any changes
        #   rule 'watch directory' do
        #     watch OpenHAB::Core.config_folder / 'items/foo.items'
        #     run { |event| logger.info("#{event.path.basename} - #{event.type}") }
        #   end
        #
        # @example Watch `items/*.items` log any changes
        #   rule 'watch directory' do
        #     watch OpenHAB::Core.config_folder / 'items/*.items'
        #     run { |event| logger.info("#{event.path.basename} - #{event.type}") }
        #   end
        #
        # @example Watch `items/*.items` for when items files are deleted or created (ignore changes)
        #   rule 'watch directory' do
        #     watch OpenHAB::Core.config_folder / 'items/*.items', for: [:deleted, :created]
        #     run { |event| logger.info("#{event.path.basename} - #{event.type}") }
        #   end
        #
        def watch(path, glob: "*", for: %i[created deleted modified], attach: nil)
          glob, path = Watch.glob_for_path(Pathname.new(path), glob)
          types = [binding.local_variable_get(:for)].flatten
          config = { path: path.to_s, types: types.map(&:to_s), glob: glob.to_s }

          logger.trace "Creating a watch trigger for #{path} with glob #{glob} on types #{types.inspect}"
          Watch.new(rule_triggers: @rule_triggers).trigger(config: config, attach: attach)
        end

        # @!endgroup

        #
        # Checks if this rule should run on start
        #
        # @return [true, false] True if rule should run on start, false otherwise.
        #
        def on_start?
          @on_start.enabled
        end

        #
        # Get the optional start attachment
        #
        # @return [Object] optional user provided attachment to the on_start method
        #
        # @!visibility private
        def start_attachment
          @on_start.attach
        end

        #
        # @return [String]
        #
        def inspect
          <<~TEXT.tr("\n", " ")
            #<OpenHAB::DSL::Rules::Builder: #{uid}
            triggers=#{triggers.inspect},
            run blocks=#{run.inspect},
            on_start=#{on_start?},
            Trigger Conditions=#{trigger_conditions.inspect},
            Trigger UIDs=#{triggers.map(&:id).inspect},
            Attachments=#{attachments.inspect}
            >
          TEXT
        end

        #
        # Process a rule based on the supplied configuration
        #
        # @param [String] script The source code of the rule
        #
        # @!visibility private
        def build(provider, script)
          return unless create_rule?

          rule = AutomationRule.new(self)
          added_rule = add_rule(provider, rule)
          # add config so that MainUI can show the script
          added_rule.actions.first.configuration.put("type", "application/x-ruby")
          added_rule.actions.first.configuration.put("script", script) if script

          rule.execute(nil, { "event" => Struct.new(:attachment).new(start_attachment) }) if on_start?
          added_rule
        end

        private

        # delegate to the caller's logger
        def logger
          @caller.send(:logger)
        end

        #
        # Should a rule be created based on rule configuration
        #
        # @return [true,false] true if it should be created, false otherwise
        #
        def create_rule?
          return true if tags.include?("Script")

          if !triggers?
            logger.warn "Rule '#{uid}' has no triggers, not creating rule"
          elsif !execution_blocks?
            logger.warn "Rule '#{uid}' has no execution blocks, not creating rule"
          elsif !enabled
            logger.trace "Rule '#{uid}' marked as disabled, not creating rule."
          else
            return true
          end
          false
        end

        #
        # Check if the rule has any triggers
        #
        # @return [true,false] True if rule has triggers, false otherwise
        #
        def triggers?
          on_start? || !triggers.empty?
        end

        #
        # Check if the rule has any execution blocks
        #
        # @return [true,false] True if rule has execution blocks, false otherwise
        #
        def execution_blocks?
          !(run || []).empty?
        end

        #
        # Add a rule to the automation manager
        #
        # @param [org.openhab.core.automation.module.script.rulesupport.shared.simple.SimpleRule] rule to add
        #
        def add_rule(provider, rule)
          base_uid = rule.uid
          duplicate_index = 1
          while $rules.get(rule.uid)
            duplicate_index += 1
            rule.uid = "#{base_uid} (#{duplicate_index})"
          end
          logger.trace("Adding rule: #{rule}")
          unmanaged_rule = Core.automation_manager.add_unmanaged_rule(rule)
          provider.add(unmanaged_rule)
          unmanaged_rule
        end
      end
    end
  end
end
