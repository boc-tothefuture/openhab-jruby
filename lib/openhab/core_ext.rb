# frozen_string_literal: true

Dir[File.expand_path("core_ext/**/*.rb", __dir__)].sort.each do |f|
  require f
end

module OpenHAB
  # @!visibility private
  module CoreExt
    # Extensions to core Java classes
    module Java
    end

    # Extensions to core Ruby classes
    module Ruby
    end
  end
end
