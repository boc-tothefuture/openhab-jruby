# frozen_string_literal: true

module OpenHAB
  module DSL
    module Events
      #
      # Event object passed by a {Rules::Builder#watch} trigger.
      #
      # @!attribute [r] path
      #   @return [Pathname] The path that had an event
      # @!attribute [r] type
      #   @return [:created, :modified, :deleted] Type of change
      # @!attribute [r] attachment
      #   @return [Object] The trigger's attachment
      WatchEvent = Struct.new(:type, :path, :attachment)
    end
  end
end
