#! /usr/bin/env ruby

plugin = File.basename(File.expand_path('.'))
spec = Gem::Specification.load("#{ plugin }.gemspec")
lib = File.expand_path('../lib')

$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require_relative "../../#{ plugin }/lib/#{ plugin }"
require 'date'
require 'json'
require 'base64'

## Environment Setup
File.open('/home/rof/.gem/credentials', 'w') do |file|
  file.write("---\n
:rubygems_api_key: #{ ENV['RG_API'] }
")
end
`chmod 0600 /home/rof/.gem/credentials`

#
# Build a gem and deploy it to rubygems
#
def deploy_rubygems(spec, plugin)
  `gem build #{ plugin }.gemspec`
  `gem push #{ spec.full_name }.gem`
end

#
# Create Github tag and release
#
def create_github_release(spec, plugin)
  `curl -H "Authorization: token #{ ENV['GITHUB_TOKEN'] }" -d '{ "tag_name": "#{ spec.version }", "target_commitish": "#{ ENV['CI_COMMIT_ID'] }", "name": "#{ spec.version }", "body": "#{ ENV['CI_MESSAGE'] }", "draft": "#{ spec.metadata['release_draft']}", "prerelease": "#{ spec.metadata['release_prerelease']}" }' https://api.github.com/repos/sensu-plugins/#{ plugin }/releases` # rubocop:disable all
end

#
# If the commit message == 'deploy bump' then doing the following
# If the commit message is anything else we just run tests
#
if ENV['CI_MESSAGE'] == 'deploy bump'
  deploy_rubygems(spec, plugin)
  create_github_release(spec, plugin)
end
