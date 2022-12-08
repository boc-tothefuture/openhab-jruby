# frozen_string_literal: true

def init
  options.objects = objects = run_verifier(options.objects)

  generate_assets
  options.files.each_with_index do |file, _i|
    serialize_file(file, file.title)
  end

  options.delete(:objects)

  objects.each do |object|
    serialize(object)
  rescue => e
    path = options.serializer.serialized_path(object)
    log.error "Exception occurred while generating '#{path}'"
    log.backtrace(e)
  end
end

def generate_assets
  @object = Registry.root

  layout = Object.new.extend(T("layout"))
  (layout.javascripts + javascripts_full_list +
      layout.stylesheets + stylesheets_full_list).uniq.each do |file|
    asset(file, file(file, true))
  end
end
