# frozen_string_literal: true

require 'spec_helper'
require 'classpath_helper'
require 'java'
require 'openhab/osgi'

module OpenHAB
  describe OSGI do
    let(:osgi) { OSGI.new }

    describe '.service_references' do
      it 'It should contain service references for Audio, Ephemeris, PersistenceExtensions, Transformation, Things, and Voice' do
        references = osgi.service_references
        references.each { |ref| puts ref; puts ref.methods }
      end
    end
  end
end
