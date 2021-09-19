# frozen_string_literal: true

require 'java'

module OpenHAB
  module DSL
    module MonkeyPatch
      #
      # Patches OpenHAB types
      #
      module Types
        java_import Java::OrgOpenhabCoreLibraryTypes::NextPreviousType

        #
        # Monkey patch for DSL use
        #
        class NextPreviousType
          alias inspect to_s
        end
      end
    end
  end
end
