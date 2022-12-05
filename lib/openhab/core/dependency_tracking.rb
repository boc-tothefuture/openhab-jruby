# frozen_string_literal: true

if defined?($dependencyListener)
  require "jruby"

  klass = Class.new(org.jruby.util.collections.StringArraySet) do
    def initialize(other)
      super(JRuby.runtime)
      other.each { |feature| append(feature) }
    end

    def append(name)
      $dependencyListener.accept(name)

      super
    end
  end

  JRuby.runtime.load_service.class.field_accessor :loadedFeatures
  JRuby.runtime.load_service.loadedFeatures = klass.new(JRuby.runtime.load_service.loadedFeatures)

  loaded_specs = Gem.loaded_specs
  loaded_specs.each_key do |gem|
    $dependencyListener.accept("gem:#{gem}")
  end

  def loaded_specs.[]=(gem, _spec)
    super

    $dependencyListener.accept("gem:#{gem}")
  end
else
  logger.warn("Dependency listener not found; dependency tracking disabled.")
end
