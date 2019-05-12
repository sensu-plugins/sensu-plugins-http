# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'github/markup'
require 'kitchen/rake_tasks'
require 'redcarpet'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'yard'
require 'yard/rake/yardoc_task'

YARD::Rake::YardocTask.new do |t|
  OTHER_PATHS = %w[].freeze
  t.files = ['lib/**/*.rb', 'bin/**/*.rb', OTHER_PATHS]
  t.options = %w[--markup-provider=redcarpet --markup=markdown --main=README.md --files CHANGELOG.md]
end

RuboCop::RakeTask.new do |r|
  r.options = %w[--display-cop-names --extra-details --display-style-guide]
end

RSpec::Core::RakeTask.new(:spec) do |r|
  r.pattern = FileList['**/**/*_spec.rb']
end

desc 'Make all plugins executable'
task :make_bin_executable do
  `chmod -R +x bin/*`
end

desc 'Test for binstubs'
task :check_binstubs do
  bin_list = Gem::Specification.load('sensu-plugins-http.gemspec').executables
  bin_list.each do |b|
    `which #{ b }`
    unless $CHILD_STATUS.success?
      puts "#{b} was not a binstub"
      exit
    end
  end
end

Kitchen::RakeTasks.new
desc 'Alias for kitchen:all'
task integration: 'kitchen:all'

task default: %i[spec make_bin_executable yard rubocop check_binstubs integration]
task quick: %i[make_bin_executable yard rubocop check_binstubs]
