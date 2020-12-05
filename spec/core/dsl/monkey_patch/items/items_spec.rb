# frozen_string_literal: true

require 'spec_helper'
require 'classpath_helper'
require 'java'

require 'openhab/core/dsl/monkey_patch/items/items'

java_import org.openhab.core.items.GenericItem

class GenericItemImpl < GenericItem
end

context 'Generic Item is MonkeyPatched' do
  let(:item) { GenericItemImpl.new('DimmerItem', 'Test') }

  describe '.to_s' do
    it 'Should return the label of the item' do
      item.label = 'Foo'
      expect(item.to_s).to eq 'Foo'
    end

    it 'Should return the name of the item if no label' do
      expect(item.to_s).to eq 'Test'
    end
  end
end
