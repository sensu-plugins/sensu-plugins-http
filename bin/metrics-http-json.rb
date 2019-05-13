#! /usr/bin/env ruby
# frozen_string_literal: false

#   metrics-http-json.rb
#
# DESCRIPTION:
#   Hits an HTTP endpoint which emits JSON and pushes data into Graphite.
#
# OUTPUT:
#   Graphite formatted data
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: rest-client
#
# USAGE:
#   EX: ./metrics-http-json.rb -u 'http://127.0.0.1:8080/jolokia/read/com\
#   .mchange.v2.c3p0:name=datasource,type=PooledDataSource' -s hostname.c3p0\
#    -m 'Connections::numConnections,BusyConnections::numBusyConnections'\
#    -o 'value'
#
# NOTES:
#   The metric option is a comma separated list of the metric (how it will
#   appear in Graphite) and the JSON key which holds the value you want to
#   graph. The object option is optional and is the name of the JSON object
#   which holds the key/value pairs you want to graph.
#
# LICENSE:
#   phamby@gmail.com
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/metric/cli'
require 'sensu/json'
require 'rest-client'
require 'socket'
require 'uri'
#
# HttpJsonGraphite - see description above
#
class HttpJsonGraphite < Sensu::Plugin::Metric::CLI::Graphite
  option :url,
         description: 'Full URL to the endpoint',
         short: '-u URL',
         long: '--url URL',
         default: 'http://localhost:8080'

  option :scheme,
         description: 'Metric naming scheme',
         short: '-s SCHEME',
         long: '--scheme SCHEME',
         default: Socket.gethostname.to_s

  option :metric,
         description: 'Metric/JSON key pair ex:Connections::numConnections',
         short: '-m METRIC::JSONKEY',
         long: '--metric METRIC::JSONKEY'

  option :object,
         description: 'The JSON object containing the data',
         short: '-o OBJECT',
         long: '--object OBJECT'

  option :insecure,
         description: 'By default, every SSL connection made is verified to be secure. This option allows you to disable the verification',
         short: '-k',
         long: '--insecure',
         boolean: true,
         default: false

  option :noproxy,
         description: 'Disable the use of any proxy enviroment variables will be used',
         short: '-n',
         long: '--noproxy',
         default: nil

  option :debug,
         short: '-d',
         long: '--debug',
         default: false

  def search_json(config, json_data)
    scheme = config[:scheme].to_s
    metric_pair_input = config[:metric].to_s

    object = config[:object].to_s if config[:object]

    metric_pair_input.split(/,/).each do |m|
      metric, attribute = m.to_s.split(/::/)
      # puts "metric: #{metric}, attribute: #{attribute}" if config[:debug]
      unless object.nil?
        json_data[object].each do |k, v|
          output([scheme, metric].join('.'), v) if k == attribute
        end
      end
      json_data.each do |k, v|
        if k.to_s == attribute
          output([scheme, metric].join('.'), v)
          break
        end
      end
    end
  end

  def run
    # TODO: figure out what to do here
    url = URI.encode(config[:url].to_s) # rubocop:disable Lint/UriEscapeUnescape

    rest_args = { url: url, method: :get, verify_ssl: !config[:insecure] }

    rest_args[:proxy] = nil if config[:noproxy]

    begin
      r = RestClient::Request.execute(rest_args)

      puts "args config: #{config}\nHttp response: #{r}\nHttp headers: #{r.headers}" if config[:debug]

      Sensu::JSON.setup!
      json_data = Sensu::JSON.load(r)
      # puts "json_data: #{json_data}" if config[:debug]

      search_json(config, json_data)
    rescue Errno::ECONNREFUSED
      critical "#{config[:url]} is not responding"
    rescue RestClient::RequestTimeout
      critical "#{config[:url]} Connection timed out"
    rescue OpenSSL::SSL::SSLError => e
      critical "#{config[:url]} error: #{e}. Try adding argument --insecure"
    rescue => e
      critical "#{config[:url]} error: #{e.inspect} - #{e}"
    end
    ok
  end
end
