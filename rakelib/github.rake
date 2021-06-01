# frozen_string_literal: true

require 'json'

OPENHAB_VERSIONS = ['3.0.2'].freeze

# rubocop: disable Metrics/BlockLength
# Disabled due to part of buid / potentially refactor into classes
namespace :github do
  def md5(filename)
    md5 = Digest::MD5.new
    File.open(filename) do |file|
      file.each(nil, 4096) { |chunk| md5 << chunk }
    end
    md5.hexdigest
  end

  desc 'Release JRuby Binding'
  task :release, [:file] do |_, args|
    bundle = args[:file]
    hash = md5(bundle)
    _, version, = File.basename(bundle, '.jar').split('-')
    sh 'gh', 'release', 'delete', version, '-y', '-R', 'boc-tothefuture/openhab2-addons'
    sh 'gh', 'release', 'create', version, '-p', '-t', 'JRuby Binding Prerelease', '-n', "md5: #{hash}", '-R',
       'boc-tothefuture/openhab2-addons', bundle
    File.write('.bundlehash', hash)
  end

  desc 'Test Matrix'
  task :matrix do
    include_map = {}
    include_map['include'] = Dir['features/**/*.feature'].map do |feature|
      OPENHAB_VERSIONS.map do |version|
        { feature: File.basename(feature, '.feature'), file: feature, openhab_version: version }
      end
    end.flatten
    puts include_map.to_json
  end

  desc 'Openhab Versions'
  task :oh_versions do
    include_map = {}
    include_map['include'] = OPENHAB_VERSIONS.map do |version|
      { openhab_version: version }
    end
    puts include_map.to_json
  end
end

# rubocop: enable Metrics/BlockLength
