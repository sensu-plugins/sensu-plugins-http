lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'date'


if RUBY_VERSION < '2.0.0'
  require 'sensu-plugins-http'
else
  require_relative 'lib/sensu-plugins-http'
end

pvt_key = '~/.ssh/gem-private_key.pem'

Gem::Specification.new do |s|
  s.name                   = 'sensu-plugins-http'
  s.version                = SensuPluginsHttp::VERSION
  s.authors                = ["Yieldbot, Inc. and contributors"]
  s.email                  = '<sensu-users@googlegroups.com>'
  s.homepage               = 'https://github.com/sensu-plugins/sensu-plugins-http'
  s.summary                = ''
  s.description            = ''
  s.license                = 'MIT'
  s.date                   = Date.today.to_s
  s.files                  = Dir.glob('{bin,lib}/**/*') + %w(LICENSE README.md CHANGELOG.md)
  s.executables            = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files             = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths          = ["lib"]
  s.cert_chain             = ["certs/sensu-plugins.pem"]
  s.signing_key            = File.expand_path(pvt_key) if $PROGRAM_NAME =~ /gem\z/
  s.platform               = Gem::Platform::RUBY
  s.required_ruby_version  = '>= 1.9.3'


  s.add_runtime_dependency 'sensu-plugin'

  s.add_development_dependency 'codeclimate-test-reporter'
  s.add_development_dependency 'rubocop', '~> 0.17.0'
  s.add_development_dependency 'rspec', '~> 3.1'
  s.add_development_dependency 'bundler', '~> 1.7'
  s.add_development_dependency 'rake', '~> 10.0'
  s.add_development_dependency 'github-markup'
  s.add_development_dependency 'redcarpet'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rest-client'
end
