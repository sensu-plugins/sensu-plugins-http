# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'date'
require 'sensu-plugins-http'

Gem::Specification.new do |s| # rubocop:disable Metrics/BlockLength
  s.authors                = ['Sensu-Plugins and contributors']
  s.date                   = Date.today.to_s
  s.description            = 'This plugin provides native HTTP instrumentation
                              for monitoring and metrics collection, including:
                              response code, JSON response, HTTP last modified,
                              SSL expiry, and metrics via `curl`.'
  s.email                  = '<sensu-users@googlegroups.com>'
  s.executables            = Dir.glob('bin/**/*.rb').map { |file| File.basename(file) }
  s.files                  = Dir.glob('{bin,lib}/**/*') + %w[LICENSE README.md CHANGELOG.md]
  s.homepage               = 'https://github.com/sensu-plugins/sensu-plugins-http'
  s.license                = 'MIT'
  s.metadata               = { 'maintainer' => 'sensu-plugin',
                               'development_status' => 'active',
                               'production_status' => 'unstable - testing recommended',
                               'release_draft' => 'false',
                               'release_prerelease' => 'false' }
  s.name                   = 'sensu-plugins-http'
  s.platform               = Gem::Platform::RUBY
  s.post_install_message   = 'You can use the embedded Ruby by setting EMBEDDED_RUBY=true in /etc/default/sensu'
  s.require_paths          = ['lib']
  s.required_ruby_version  = '>= 2.3.0'
  s.summary                = 'Sensu plugins for various http monitors and metrics'
  s.test_files             = s.files.grep(%r{^(test|spec|features)/})
  s.version                = SensuPluginsHttp::Version::VER_STRING

  s.add_runtime_dependency 'sensu-plugin', '~> 4.0'

  s.add_runtime_dependency 'aws-sdk', '~> 2.3'
  s.add_runtime_dependency 'oj', '~> 2.18'
  s.add_runtime_dependency 'rest-client', '~> 2.0.2'
  s.add_runtime_dependency 'typhoeus', '~> 1.3.1'

  s.add_development_dependency 'bundler',                   '~> 2.1'
  s.add_development_dependency 'github-markup',             '~> 3.0'
  s.add_development_dependency 'json',                      '< 2.0.0'
  s.add_development_dependency 'kitchen-docker',            '~> 2.6'
  s.add_development_dependency 'kitchen-localhost',         '~> 0.3'
  s.add_development_dependency 'kitchen-vagrant',           '~> 1.3'
  s.add_development_dependency 'pry',                       '~> 0.10'
  s.add_development_dependency 'rake',                      '~> 12.3'
  s.add_development_dependency 'rdoc'
  s.add_development_dependency 'redcarpet',                 '~> 3.2'
  s.add_development_dependency 'rspec',                     '~> 3.1'
  s.add_development_dependency 'rubocop',                   '~> 0.79.0'
  s.add_development_dependency 'test-kitchen',              '~> 1.25.0'
  s.add_development_dependency 'yard',                      '~> 0.9.11'
end
