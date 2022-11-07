# frozen_string_literal: true

# https://github.com/rails/rails/blob/main/activesupport/lib/active_support/core_ext/array/wrap.rb
class Array
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
