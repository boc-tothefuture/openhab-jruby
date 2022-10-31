# frozen_string_literal: true

module OpenHAB
  #
  # Contains loaded Ruby transformations as class methods
  #
  # Only during testing.
  #
  # @example Corresponds to `transform/compass.script`
  #   OpenHAB::Transform.compass("59 °")
  #
  # @example Corresponds to `transform/compass.script`
  #   OpenHAB::Transform.compass("30", param: "7")
  #
  # @example Corresponds to `transform/ruby/compass.script`
  #   OpenHAB::Transform::Ruby.compass("59 °")

  module Transform
    class << self
      # @!visibility private
      def add_script(modules, script)
        full_name = modules.join("/")
        name = modules.pop
        (@scripts ||= {})[full_name] = engine_factory.script_engine.compile(script)

        mod = modules.inject(self) { |m, n| m.const_get(n, false) }
        mod.singleton_class.define_method(name) do |input, **kwargs|
          Transform.send(:transform, full_name, input, kwargs)
        end
      end

      private

      def engine_factory
        @engine_factory ||= org.jruby.embed.jsr223.JRubyEngineFactory.new
      end

      def transform(name, input, kwargs)
        script = @scripts[name]
        ctx = script.engine.context
        ctx.set_attribute("input", input.to_s, javax.script.ScriptContext::ENGINE_SCOPE)
        kwargs.each do |(k, v)|
          ctx.set_attribute(k.to_s, v.to_s, javax.script.ScriptContext::ENGINE_SCOPE)
        end
        script.eval
      end
    end
  end
end

module OpenHAB
  module RSpec
    #
    # Provides helper methods for use in specs, to easily work with and adjust
    # the OpenHAB environment.
    #
    # These methods are automatically available in RSpec spec blocks, as well
    # as other per-spec hooks like `before` and `after`. You can also call them
    # explicitly.
    #
    module Helpers
      module BindingHelper
        # @!visibility private
        def add_kwargs_to_current_binding(binding, kwargs)
          kwargs.each { |(k, v)| binding.local_variable_set(k, v) }
        end
      end
      private_constant :BindingHelper

      # Yard crashes on this; be tricky so it doesn't realize what's going on
      s = singleton_class
      s.include(Helpers)

      module_function

      #
      # Reconfigure all items to autoupdate
      #
      # To bypass any items configured to not autoupdate, waiting for the binding to update them.
      #
      # @return [void]
      #
      def autoupdate_all_items
        if instance_variable_defined?(:@autoupdated_items)
          raise RuntimeError "You should only call `autoupdate_all_items` once per spec"
        end

        @autoupdated_items = []

        $ir.for_each do |_provider, item|
          if item.meta.key?("autoupdate")
            @autoupdated_items << item.meta.delete("autoupdate")
            item.meta["autoupdate"] = true
          end
        end
      end

      #
      # Execute all pending timers
      #
      # @return [void]
      #
      def execute_timers
        DSL::Timer::Manager.instance.execute_timers
      end

      #
      # Suspend rules for the duration of the block
      #
      # @return [Object] The return value from the block.
      #
      def suspend_rules(&block)
        SuspendRules.suspend_rules(&block)
      end

      #
      # Manually trigger a rule by ID
      #
      # @param [String] uid The rule ID
      # @param [Object, nil] event The event to pass to the rule's execution blocks.
      # @return [void]
      #
      def trigger_rule(uid, event = nil)
        DSL::Rules.script_rules.fetch(uid).execute(nil, { "event" => event })
      end

      #
      # Manually send an event to a trigger channel
      #
      # @param [String, Channel, ChannelUID] channel The channel to trigger.
      # @param [String] event The event data to send to the channel.
      # @return [void]
      #
      def trigger_channel(channel, event = "")
        channel = org.openhab.core.thing.ChannelUID.new(channel) if channel.is_a?(String)
        channel = channel.uid if channel.is_a?(org.openhab.core.thing.Channel)
        thing = channel.thing
        thing.handler.callback.channel_triggered(nil, channel, event)
      end

      #
      # Require all files configured to be autorequired with the jrubyscripting addon in OpenHAB.
      #
      # This method is normally called by RSpec hooks.
      #
      # @return [void]
      #
      def autorequires
        requires = jrubyscripting_config&.get("require") || ""
        requires.split(",").each do |f|
          require f.strip
        end
      end

      #
      # Launch the karaf instance
      #
      # This method is normally called by RSpec hooks.
      #
      # @return [void]
      # @see Configuration
      #
      def launch_karaf(include_bindings: true,
                       include_jsondb: true,
                       private_confdir: false,
                       use_root_instance: false)
        karaf = Karaf.new("#{Dir.pwd}/.karaf")
        karaf.include_bindings = include_bindings
        karaf.include_jsondb = include_jsondb
        karaf.private_confdir = private_confdir
        karaf.use_root_instance = use_root_instance
        main = karaf.launch

        ENV["RUBYLIB"] ||= ""
        ENV["RUBYLIB"] += ":" unless ENV["RUBYLIB"].empty?
        ENV["RUBYLIB"] += rubylib_dir
        require "openhab/dsl"

        require_relative "mocks/persistence_service"

        # override several DSL methods
        require_relative "openhab/core/items/proxy"
        require_relative "openhab/core/things/thing"
        require_relative "openhab/dsl/actions"
        require_relative "openhab/dsl/timer"

        ps = Mocks::PersistenceService.instance
        bundle = org.osgi.framework.FrameworkUtil.get_bundle(org.openhab.core.persistence.PersistenceService)
        bundle.bundle_context.register_service(org.openhab.core.persistence.PersistenceService.java_class, ps, nil)

        # wait for the rule engine
        rs = OSGi.service("org.openhab.core.service.ReadyService")
        filter = org.openhab.core.service.ReadyMarkerFilter.new
                    .with_type(org.openhab.core.service.StartLevelService::STARTLEVEL_MARKER_TYPE)
                    .with_identifier(org.openhab.core.service.StartLevelService::STARTLEVEL_RULEENGINE.to_s)

        karaf.send(:wait) do |continue|
          rs.register_tracker(org.openhab.core.service.ReadyService::ReadyTracker.impl { continue.call }, filter)
        end

        # RSpec additions
        require_relative "suspend_rules"

        if defined?(::RSpec)
          ::RSpec.configure do |config|
            config.include OpenHAB::DSL
          end
        end
        main
      rescue Exception => e
        puts e.inspect
        puts e.backtrace
        raise
      end

      #
      # Load all Ruby rules in the config/automation directory
      #
      # This method is normally called by RSpec hooks.
      #
      # @return [void]
      #
      def load_rules
        automation_path = "#{org.openhab.core.OpenHAB.config_folder}/automation/jsr223"

        SuspendRules.suspend_rules do
          files = Dir["#{automation_path}/**/*.rb"]
          files.sort_by { |f| [get_start_level(f), f] }.each do |f|
            load f
          rescue Exception => e
            warn "Failed loading #{f}: #{e.inspect}"
            warn e.backtrace
          end
        end
      end

      #
      # Load all Ruby transformations in the config/transform directory
      #
      # Since Ruby transformations must end with the .script extension, you must include
      # an Emacs modeline comment (`# -*- mode: ruby -*-`) in your script for it to be
      # recognized.
      #
      # This method is normally called by RSpec hooks.
      #
      # @return [void]
      #
      def load_transforms
        transform_path = "#{org.openhab.core.OpenHAB.config_folder}/transform"
        Dir["#{transform_path}/**/*.script"].each do |filename|
          script = File.read(filename)
          next unless ruby_file?(script)

          filename.slice!(0..transform_path.length)
          dir = File.dirname(filename)
          modules = (dir == ".") ? [] : moduleize(dir)
          basename = File.basename(filename)
          method = basename[0...-7]
          modules << method
          Transform.add_script(modules, script)
        end
      end

      #
      # Install an OpenHAB addon
      #
      # @param [String] addon_id The addon id, such as "binding-mqtt"
      # @param [true,false] wait Wait until OSGi has confirmed the bundle is installed and running before returning.
      # @param [String,Array<String>] ready_markers Array of ready marker types to wait for.
      #   The addon's bundle id is used as the identifier.
      # @return [void]
      #
      def install_addon(addon_id, wait: true, ready_markers: nil)
        addon_service = OSGi.service("org.openhab.core.addon.AddonService")
        addon_service.install(addon_id)
        return unless wait

        addon = nil
        loop do
          addon = addon_service.get_addon(addon_id, nil)
          break if addon.installed?

          sleep 0.25
        end

        return unless ready_markers

        package_id = addon.logger_packages.first

        ready_markers = Array(ready_markers).map do |marker|
          case marker
          when String
            org.openhab.core.service.ReadyMarker.new(marker, package_id)
          else
            marker
          end
        end

        rs = OSGi.service("org.openhab.core.service.ReadyService")
        loop do
          break if ready_markers.all? { |rm| rs.ready?(rm) }

          sleep 0.25
        end
      end

      private

      def jrubyscripting_config
        ca = OSGi.service("org.osgi.service.cm.ConfigurationAdmin")
        ca.get_configuration("org.openhab.automation.jrubyscripting", nil)&.properties
      end

      def rubylib_dir
        jrubyscripting_config&.get("rubylib") || "#{org.openhab.core.OpenHAB.config_folder}/automation/lib/ruby"
      end

      def get_start_level(file)
        return ($1 || $2).to_i if file =~ %r{/sl(\d{2})/[^/]+$|\.sl(\d{2})\.[^/.]+$}

        50
      end

      EMACS_MODELINE_REGEXP = /# -\*-(.+)-\*-/.freeze
      private_constant :EMACS_MODELINE_REGEXP

      def parse_emacs_modeline(line)
        line[EMACS_MODELINE_REGEXP, 1]
            &.split(";")
            &.map(&:strip)
            &.map { |l| l.split(":", 2).map(&:strip).tap { |a| a[1] ||= nil } }
            &.to_h
      end

      def ruby_file?(script)
        # check the first 1KB for an emacs magic comment
        script[0..1024].split("\n").any? { |line| parse_emacs_modeline(line)&.dig("mode") == "ruby" }
      end

      def moduleize(term)
        term
          .sub(/^[a-z\d]*/, &:capitalize)
          .gsub(%r{(?:_|(/))([a-z\d]*)}) { "#{$1}#{$2.capitalize}" }
          .split("/")
      end

      # need to transfer autoupdate metadata from GenericMetadataProvider to ManagedMetadataProvider
      # so that we can mutate it in the future
      def set_up_autoupdates
        gmp = OSGi.service("org.openhab.core.model.item.internal.GenericMetadataProvider")
        mr = OSGi.service("org.openhab.core.items.MetadataRegistry")
        mmp = mr.managed_provider.get
        to_add = []
        gmp.all.each do |metadata|
          next unless metadata.uid.namespace == "autoupdate"

          to_add << metadata

          # 3.2.0 can't remove single namespaces from the GenericMetadataProvider, so
          # we have to remove everything from the item
          unless gmp.respond_to?(:remove_metadata_by_namespace)
            to_add.concat(gmp.all.select { |m2| m2.uid.item_name == metadata.uid.item_name })
            gmp.remove_metadata(metadata.uid.item_name)
          end
        end
        gmp.remove_metadata_by_namespace("autoupdate") if gmp.respond_to?(:remove_metadata_by_namespace)

        to_add.each do |m|
          if mmp.get(m.uid)
            mmp.update(m)
          else
            mmp.add(m)
          end
        end
      end

      def restore_autoupdate_items
        return unless instance_variable_defined?(:@autoupdated_items)

        mr = OSGi.service("org.openhab.core.items.MetadataRegistry")
        @autoupdated_items&.each do |meta|
          mr.update(meta)
        end
        @autoupdated_items = nil
      end
    end

    if defined?(::RSpec)
      ::RSpec.configure do |config|
        config.include Helpers
      end
    end
  end
end
