# frozen_string_literal: true

require 'yard'

namespace :docs do
  yard_dir = File.join('docs', 'yard')

  CLEAN << yard_dir
  CLEAN << '.yardoc'

  desc 'Generate Yard Docs'
  task :yard do
    YARD::Rake::YardocTask.new do |t|
      t.files = ['lib/**/*.rb'] # optional
      t.stats_options = ['--list-undoc'] # optional
    end
  end

  desc 'Start Jekyll Documentation Server'
  task :jeykll => :yard do
    sh 'bundle exec jekyll clean'
    sh 'bundle exec jekyll server --config docs/_config.yml'
  end
end
