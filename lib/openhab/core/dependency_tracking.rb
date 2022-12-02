# frozen_string_literal: true

if defined?($dependency_listener)
  require "jruby"

  klass = Class.new(org.jruby.util.collections.StringArraySet) do
    def initialize(other)
      super(JRuby.runtime)
      other.each { |feature| append(feature) }
    end

    def append(name)
      $dependency_listener.accept(name)

      super
    end
  end

  JRuby.runtime.load_service.class.field_accessor :loadedFeatures
  JRuby.runtime.load_service.loadedFeatures = klass.new(JRuby.runtime.load_service.loadedFeatures)

  loaded_specs = Gem.loaded_specs
  loaded_specs.each_key do |gem|
    $dependency_listener.accept("gem:#{gem}")
  end

  def loaded_specs.[]=(gem, _spec)
    super

    $dependency_listener.accept("gem:#{gem}")
  end
else
  logger.warn("Dependency listener not found; dependency tracking disabled.")
end
