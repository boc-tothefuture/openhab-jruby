# frozen_string_literal: true

def serialize(object)
  return if object == "_index.html"

  super
end
