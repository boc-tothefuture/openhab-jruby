# frozen_string_literal: true

# Extensions to Symbol
class Symbol
  # Ruby 3.0 already has #name
  alias_method :name, :to_s unless instance_methods.include?(:name)
end
