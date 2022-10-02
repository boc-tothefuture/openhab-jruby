# frozen_string_literal: true

RSpec.describe OpenHAB::DSL::Items::StringItem do
  subject(:item) { StringOne }

  before do
    items.build do
      group_item 'Strings' do
        string_item 'StringOne', state: 'Hello'
        string_item 'StringTwo', state: 'World!'
        string_item 'StringThree'
      end
    end
  end

  it 'supports string operations' do
    expect(item + ' World!').to eql 'Hello World!' # rubocop:disable Style/StringConcatenation
  end

  it 'acts as a string for other string operations' do
    expect('Hello ' + item).to eql 'Hello Hello' # rubocop:disable Style/StringConcatenation
  end

  it 'works with grep' do
    #    StringThree.update("hi")
    items.build { switch_item 'SwitchOne' }
    expect(items.grep(StringItem)).to match_array [StringOne, StringTwo, StringThree]
  end

  it 'can be used in a case with a regex' do
    expect(case item
           when /Hello/ then true
           end).to be true
  end

  it 'works with grep and a regex' do
    StringThree.update('foobar')

    expect(Strings.grep(/^H/)).to eql [StringOne]
  end

  describe '#blank?' do
    it 'works' do
      items.build do
        group_item 'BlankStrings' do
          string_item 'NullString', state: NULL
          string_item 'UndefString', state: UNDEF
          string_item 'WhitespaceString', state: ' '
        end
      end

      expect(BlankStrings).to all(be_blank)
      expect(item).not_to be_blank
    end
  end

  describe 'comparisons' do
    before { StringThree.update('Hello') }

    specify { expect(item == 'Hello').to be true }
    specify { expect(item == 'World').to be false }
    specify { expect(item != 'Hello').to be false }
    specify { expect(item != 'World').to be true }
    specify { expect(StringOne == StringTwo).to be false }
    specify { expect(StringOne != StringTwo).to be true }
    specify { expect(StringOne == StringThree).to be true }
    specify { expect(StringOne != StringThree).to be false }
  end
end
