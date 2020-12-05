# frozen_string_literal: true

require 'spec_helper'
require 'classpath_helper'
require 'java'

require 'openhab/core/dsl/monkey_patch/types/percent_type'

module OpenHAB
  module Core
    module DSL
      module MonkeyPatch
        module Type
          describe Java::OrgOpenhabCoreLibraryTypes::PercentType do
            context 'PercentType inherits from DecimalType' do
              let(:type) { PercentType.new(50) }

              it 'It should return true when compared to a Ruby integer of the same amount' do
                expect(type == 50).to be true
              end
            end
          end
        end
      end
    end
  end
end
