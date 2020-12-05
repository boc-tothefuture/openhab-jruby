# frozen_string_literal: true

require 'spec_helper'
require 'classpath_helper'
require 'java'

require 'openhab/core/dsl/monkey_patch/ruby/range'

java_import org.openhab.core.library.items.DimmerItem
java_import org.openhab.core.library.items.NumberItem
java_import org.openhab.core.library.types.PercentType
java_import org.openhab.core.library.types.DecimalType
java_import org.openhab.core.library.types.OnOffType

describe '..' do
  context 'With a dimmer item' do
    let(:dimmer) { DimmerItem.new('Test') }

    it 'should return true from case if in the range' do
      dimmer.setState(PercentType.new(30))

      returned = case dimmer
                 when 0..25
                   false
                 when 25..66
                   true
                 when 66..100
                   false
                 end
      expect(returned).to be true
    end
  end

  context 'With a number item' do
    let(:num) { NumberItem.new('Test') }

    it 'should return true from case if in the range' do
      num.setState(DecimalType.new(30))

      returned = case num
                 when 0..25
                   false
                 when 25..66
                   true
                 when 66..100
                   false
                 end
      expect(returned).to be true
    end
  end
end
