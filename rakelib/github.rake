# frozen_string_literal: true

require 'json'

OPENHAB_VERSIONS = ['3.1.0', '3.2.0.M1'].freeze

# rubocop: disable Metrics/BlockLength
# Disabled due to part of buid / potentially refactor into classes
namespace :github do
  desc 'Release JRuby Binding'
  task :release, [:file] do |_, args|
    bundle = args[:file]
    hash = Digest::MD5.hexdigest(File.read(bundle))
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
