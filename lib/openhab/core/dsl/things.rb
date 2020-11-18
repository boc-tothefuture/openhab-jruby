# frozen_string_literal: true

require 'java'

module Things
  # rubocop: disable Style/GlobalVars
  def things
    $things.getAll
  end

  # rubocop: enable Style/GlobalVars
end
