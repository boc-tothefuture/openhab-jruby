# frozen_string_literal: true

module OpenHAB
  #
  # This module contains helper methods, hooks, and infrastracture to
  # boot OpenHAB inside of JRuby, and run RSpec (or other Ruby processes)
  # in that context.
  #
  # @see file:testing.md Testing Your Rules
  #
  module RSpec
    Object.include Helpers if defined?(IRB)

    Helpers.launch_karaf(
      include_bindings: Configuration.include_bindings,
      include_jsondb: Configuration.include_jsondb,
      private_confdir: Configuration.private_confdir,
      use_root_instance: Configuration.use_root_instance
    )

    if defined?(::RSpec)
      ::RSpec.configure do |config|
        require_relative "example_group"
        config.include ExampleGroup

        config.before(:suite) do
          Helpers.autorequires unless Configuration.private_confdir
          Helpers.send(:set_up_autoupdates)
          Helpers.load_transforms
          Helpers.load_rules
        end

        config.before do
          suspend_rules do
            $ir.for_each do |_provider, item|
              next if item.is_a?(GroupItem) # groups only have calculated states

              item.state = NULL unless item.raw_state == NULL
            end
          end
          @known_rules = Core.rule_registry.all.map(&:uid)
        end

        config.before do |example|
          @item_provider = DSL::Items::ItemProvider.send(:new)
          allow(DSL::Items::ItemProvider).to receive(:instance).and_return(@item_provider)
          @thing_provider = DSL::Things::ThingProvider.send(:new)
          allow(DSL::Things::ThingProvider).to receive(:instance).and_return(@thing_provider)
          @item_channel_link_provider = DSL::Items::ItemChannelLinkProvider.send(:new)
          allow(DSL::Items::ItemChannelLinkProvider).to receive(:instance).and_return(@item_channel_link_provider)
          mr = Core::Items::Metadata::NamespaceHash.registry
          @metadata_provider = Mocks::MetadataProvider.new(mr.managed_provider.get)
          mr.add_provider(@metadata_provider)
          mr.set_managed_provider(@metadata_provider)
          tm = OSGi.service("org.openhab.core.thing.ThingManager")
          tm.class.field_reader :storage
          tm.storage.keys.each { |k| tm.storage.remove(k) } # rubocop:disable Style/HashEachMethods not a hash
          @log_index = File.size(log_file)
          profile_factory = Core::ProfileFactory.send(:new)
          @profile_factory_registration = OSGi.register_service(profile_factory)
          allow(Core::ProfileFactory).to receive(:instance).and_return(profile_factory)
          stub_const("OpenHAB::Core::Timer", Mocks::Timer) if self.class.mock_timers?
          log_line = "rspec #{example.location} # #{example.full_description}"
          logger.info(log_line)
          Logger.events.info(log_line)
        end

        config.after do
          # remove rules created during the spec
          (Core.rule_registry.all.map(&:uid) - @known_rules).each do |uid|
            remove_rule(uid) if defined?(remove_rule)
          end
          $ir.remove_provider(@item_provider)
          Core::Items::Proxy.reset_cache
          $things.remove_provider(@thing_provider)
          Core::Things::Proxy.reset_cache
          registry = OSGi.service("org.openhab.core.thing.link.ItemChannelLinkRegistry")
          registry.remove_provider(@item_channel_link_provider)
          Core::Items::Metadata::NamespaceHash.registry.remove_provider(@metadata_provider)
          @metadata_provider.restore_parent
          @profile_factory_registration.unregister
          DSL::TimerManager.instance.cancel_all
          Timecop.return
          restore_autoupdate_items
          Mocks::PersistenceService.instance.reset
        end
      end
    end
  end
end
