# frozen_string_literal: true

require 'java'

module OpenHAB
  module DSL
    module MonkeyPatch
      #
      # Patches OpenHAB types
      #
      module Types
        java_import Java::OrgOpenhabCoreLibraryTypes::IncreaseDecreaseType

        #
        # Monkey patch for DSL use
        #
        class IncreaseDecreaseType
          alias inspect to_s
        end
      end
    end
  end
end
