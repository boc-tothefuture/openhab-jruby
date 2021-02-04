# frozen_string_literal: true

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
end
