# frozen_string_literal: true

# Extensions to Class
class Class
  #
  # Returns the name of the class, without any containing module or package.
  #
  # @return [String, nil]
  #
  def simple_name
    return unless name

    @simple_name ||= java_class&.simple_name || name.split("::").last
  end
end
