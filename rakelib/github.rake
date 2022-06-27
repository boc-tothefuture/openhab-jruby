# frozen_string_literal: true

require 'json'
require 'open3'
require 'pp'

OPENHAB_VERSIONS = ['3.2.0', '3.3.0'].freeze

# Get list
# rubocop: disable Metrics/MethodLength
def features
  stdout, stderr, status = Open3.capture3('bundle exec cucumber -d -f json')
  raise stderr.to_s unless status.success?

  matching_keywords = ['Scenario', 'Scenario Outline']
  feature_json = JSON.parse(stdout)
  feature_json.each_with_object([]) do |feature, feature_list|
    uri = feature['uri']
    feature['elements'].each do |element|
      keyword = element['keyword']
      feature_list << "#{uri}:#{element['line']}" if matching_keywords.include?(keyword)
    end
  end
end
# rubocop: enable Metrics/MethodLength

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
  task :matrix, [:runners] do |_, args|
    runners = args[:runners].to_i
    # puts "Creating matrix for #{runners} runners"
    versions = OPENHAB_VERSIONS.length
    runners_per_version = runners / versions
    # puts "Splitting across #{versions} versions of OpenHAB with #{runners_per_version} runners per version"
    feature_list = features
    # shuffle feature list as often slower tests are in the same feature file
    feature_list = feature_list.shuffle
    features_per_runner = (feature_list.length / runners_per_version.to_f).ceil
    # puts "#{feature_list.length} total features,  #{features_per_runner} features per runner"

    include_list = feature_list
                   .each_slice(features_per_runner).to_a
                   .map do |features|
      OPENHAB_VERSIONS.map do |version|
        { features: features.join(' '), openhab_version: version }
      end
    end.flatten

    include_map = {}
    include_map['include'] = include_list.map.with_index(1) { |element, i| element.merge({ index: i }) }
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
