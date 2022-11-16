# frozen_string_literal: true

require "json"
require "open3"
require "pp"

OPENHAB_VERSIONS = ["3.3.0"].freeze

namespace :github do
  desc "Release JRuby Binding"
  task :release, [:file] do |_, args|
    bundle = args[:file]
    hash = Digest::MD5.hexdigest(File.read(bundle))
    _, version, = File.basename(bundle, ".jar").split("-")
    sh "gh", "release", "delete", version, "-y", "-R", "boc-tothefuture/openhab2-addons"
    sh "gh", "release", "create", version, "-p", "-t", "JRuby Binding Prerelease", "-n", "md5: #{hash}", "-R",
       "boc-tothefuture/openhab2-addons", bundle
    File.write(".bundlehash", hash)
  end

  desc "OpenHAB Versions Matrix"
  task :oh_versions_matrix do
    include_map = {}
    include_map["include"] = OPENHAB_VERSIONS.map do |version|
      { openhab_version: version }
    end
    puts include_map.to_json
  end
end
