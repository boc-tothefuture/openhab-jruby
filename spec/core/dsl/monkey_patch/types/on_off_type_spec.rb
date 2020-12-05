# frozen_string_literal: true

require 'spec_helper'
require 'classpath_helper'
require 'java'

require 'openhab/core/dsl/monkey_patch/types/on_off_type'
require 'openhab/core/dsl/monkey_patch/items/switch_item'
require 'openhab/core/dsl/monkey_patch/items/dimmer_item'

module OpenHAB
  module Core
    module DSL
      module MonkeyPatch
        module Type
          java_import org.openhab.core.library.items.SwitchItem
          java_import org.openhab.core.library.items.DimmerItem
          java_import org.openhab.core.library.types.OnOffType

          describe Java::OrgOpenhabCoreLibraryTypes::OnOffType do
            context 'OnOff Type is Monkey Patched' do
              switch =   SwitchItem.new('Switch')
              dimmer =   DimmerItem.new('Dimmer')

              [switch, dimmer].each do |item|
                it "Case on #{item} should return true for case equals of type ON if item state is ON" do
                  item.setState(OnOffType::ON)

                  eval = case item
                         when OnOffType::ON
                           true
                         when OnOffType::OFF
                           false
                         end
                  expect(eval).to be true
                end

                it "Case on #{item} should return true for case equals of type OFF if item state is OFF" do
                  item.setState(OnOffType::OFF)

                  eval = case item
                         when OnOffType::ON
                           false
                         when OnOffType::OFF
                           true
                         end
                  expect(eval).to be true
                end
              end
            end
          end
        end
      end
    end
  end
end
