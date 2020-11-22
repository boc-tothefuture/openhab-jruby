# frozen_string_literal: true

require 'spec_helper'
require 'classpath_helper'
require 'java'

require 'openhab/core/dsl/monkey_patch/type/open_closed_type'

module OpenHAB
  module Core
    module DSL
      module MonkeyPatch
        module Type
          java_import org.openhab.core.library.items.ContactItem
          java_import org.openhab.core.library.types.OpenClosedType
          describe Java::OrgOpenhabCoreLibraryTypes::OpenClosedType do
            context 'Open Closed Type is Monkey Patched' do
              let(:contact) { ContactItem.new('TestContact') }

              it 'It should return true for case equals of type Closed if Item state is Closed' do
                contact.setState(OpenClosedType::CLOSED)

                eval = case contact
                       when OpenClosedType::OPEN
                         false
                       when OpenClosedType::CLOSED
                         true
                       end
                expect(eval).to be true
              end

              it 'It should return true for case equals of type Open if Item state is Open' do
                contact.setState(OpenClosedType::OPEN)

                eval = case contact
                       when OpenClosedType::OPEN
                         true
                       when OpenClosedType::CLOSED
                         false
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
