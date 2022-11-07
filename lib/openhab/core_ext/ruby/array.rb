# frozen_string_literal: true

# https://github.com/rails/rails/blob/main/activesupport/lib/active_support/core_ext/array/wrap.rb
class Array
  # Ensure an object is an array, by wrapping
  # it in an array if it's not already an array.
  def self.wrap(object)
    if object.nil?
      []
    elsif object.respond_to?(:to_ary)
      object.to_ary
    else
      [object]
    end
  end
end
