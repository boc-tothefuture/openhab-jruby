# frozen_string_literal: true

require 'securerandom'

module Triggers
  def uuid
    SecureRandom.uuid
  end
end
