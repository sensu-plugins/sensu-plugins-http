#! /usr/bin/env ruby
#
#   metrics-http-json-deep
#
# DESCRIPTION:
#   Get metrics in json format via http/https
#
# OUTPUT:
#   metric data
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: uri
#   gem: socket
#   gem: oj
#
# USAGE:
#
# NOTES:
#
# LICENSE:
#   Copyright 2016 Hayato Matsuura
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/metric/cli'
require 'net/https'
require 'uri'
require 'socket'
require 'oj'

#
# JSON Metrics
#
class JsonDeepMetrics < Sensu::Plugin::Metric::CLI::Graphite
  option :url,
         short: '-u URL',
         long: '--url URL',
         description: 'Full URL to JSON, example: https://example.com/foo.json This ignores --hostname and --port options'

  option :hostname,
         short: '-h HOSTNAME',
         long: '--host HOSTNAME',
         description: 'App server hostname',
         default: '127.0.0.1'

  option :port,
         short: '-P PORT',
         long: '--port PORT',
         description: 'App server port',
         default: '80'

  option :path,
         short: '-p PATH',
         long: '--path ROOTPATH',
         description: 'Path for json',
         default: 'status'

  option :root,
         short: '-r ROOTPATH',
         long: '--rootpath ROOTPATH',
         description: 'Root attribute for json',
         default: 'value'

  option :scheme,
         description: 'Metric naming scheme, text to prepend to metric',
         short: '-s SCHEME',
         long: '--scheme SCHEME',
         default: "#{Socket.gethostname}.json"

  option :numonly,
         description: 'Output numbers only',
         short: '-n',
         long: '--number'

  def deep_value(hash, scheme = '')
    hash.each do |key, value|
      if value.is_a?(Hash)
        deep_value(value, "#{scheme}.#{key}")
      else
        output "#{scheme}.#{key}", value unless config[:numonly] && !value.is_a?(Fixnum)
      end
    end
  end

  def run
    found = false
    attempts = 0
    until found || attempts >= 10
      attempts += 1
      if config[:url]
        uri = URI.parse(config[:url])
        http = Net::HTTP.new(uri.host, uri.port)
        if uri.scheme == 'https'
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        request = Net::HTTP::Get.new(uri.request_uri)
        response = http.request(request)
        if response.code == '200'
          found = true
        elsif !response.header['location'].nil?
          config[:url] = response.header['location']
        end
      else
        response = Net::HTTP.start(config[:hostname], config[:port]) do |connection|
          request = Net::HTTP::Get.new("/#{config[:path]}")
          connection.request(request)
        end
      end
    end # until

    metrics = Oj.load(response.body, mode: :compat)
    deep_value(metrics[config[:root]], config[:scheme])
    ok
  end
end
