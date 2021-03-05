# frozen_string_literal: true

require 'java'

module OpenHAB
  module DSL
    #
    # Ruby implementation of OpenHAB Types
    #
    module Types
      java_import Java::OrgOpenhabCoreLibraryTypes::PointType
      ::Point = PointType
    end
  end
end
