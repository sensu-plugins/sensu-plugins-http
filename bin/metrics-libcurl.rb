#!/usr/bin/env ruby
# frozen_string_literal: false

#
#   metrics-libcurl
#
# DESCRIPTION:
#   Simple wrapper around libcurl for getting timing stats from the various phases
#   of connecting to an HTTP/HTTPS server.
#
# OUTPUT:
#   metric data
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: typhoeus
#
# USAGE:
#   #YELLOW
#
# NOTES:
#   Based on: metrics-curl.rb
#   by Joe Miller.
#
# LICENSE:
#   Copyright 2019 Jef Spaleta
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'socket'
require 'English'
require 'sensu-plugin/metric/cli'
require 'typhoeus'
require 'json'

#
# Libcurl Metrics
#
class LibcurlMetrics < Sensu::Plugin::Metric::CLI::Graphite
  option :url,
         short: '-u URL',
         long: '--url URL',
         description: 'valid cUrl url to connect (default: http://127.0.0.1:80/)',
         default: 'http://127.0.0.1:80/'

  option :scheme,
         description: 'Metric naming scheme, text to prepend to metric',
         short: '-s SCHEME',
         long: '--scheme SCHEME',
         default: "#{Socket.gethostname}.curl_timings"
  option :debug,
         description: 'Include debug output, should not use in production.',
         short: '-d',
         long: '--debug',
         default: false
  option :libcurl_options,
         description: 'Libcurl Options as a key/value JSON string',
         short: '-o JSON',
         long: '--options  JSON',
         default: '{}'
  option :http_headers,
         description: 'HTTP Request Headers as key/value JSON string',
         short: '-H JSON',
         long: '--headers  JSON',
         default: '{}'
  option :http_params,
         description: 'HTTP Request Parameters as key/value JSON string',
         short: '-P JSON',
         long: '--params  JSON',
         default: '{}'
  option :http_response_error,
         description: 'return critical status (2) if http response error status encountered (>= 400)',
         short: '-c',
         long: '--critical_http_error',
         default: false
  option :http_redirect_warning,
         description: 'return warning status (1) if http response redirect status encountered (3xx)',
         short: '-w',
         long: '--warn_redirect',
         default: false
  option :help,
         short: '-h',
         long: '--help',
         description: 'Show this message',
         on: :tail,
         boolean: true,
         show_options: true

  def usage_details
    <<~USAGE
      Detailed Info:
        This wrapper makes use of libcurl directly instead of the curl executable by way of the Typhoeus RubyGem.
        You can provide additional libcurl options via the commandline using the --options argument.

      Options Examples:
        Follow Redirects: --options '{\"followlocation\": true}'
        Use Proxy: --options '{proxy: \"http://proxyurl.com\", proxyuserpwd: \"user:password\"}'
        Disable TLS Verification: '{\"ssl_verifypeer\": false}'

      References:
        Typhoeus Docs: https://www.rubydoc.info/gems/typhoeus/1.3.1
        Libcurl Options: https://curl.haxx.se/libcurl/c/curl_easy_setopt.html
    USAGE
  end

  def run
    if config[:help]
      puts usage_details
      ok
    end

    puts "[DEBUG] args config: #{config}" if config[:debug]
    begin
      headers = ::JSON.parse(config[:http_headers])
    rescue ::JSON::ParserError
      critical "Error parsing http_headers JSON\n"
    end
    begin
      params = ::JSON.parse(config[:http_params])
    rescue ::JSON::ParserError
      critical "Error parsing http_params JSON\n"
    end
    begin
      hash = ::JSON.parse(config[:libcurl_options])
    rescue ::JSON::ParserError
      critical "Error parsing libcurl_options JSON\n"
    end

    begin
      opts = Hash[hash.map { |k, v| [k.to_sym, v] }]
      opts[:headers] = headers unless headers.empty?
      opts[:params] = params unless params.empty?
      request = Typhoeus::Request.new(config[:url], opts)
      if config[:debug]
        puts "[DEBUG] Request Options: #{request.options}"
        puts "[DEBUG] Request Base Url: #{request.base_url}"
        puts "[DEBUG] Request Full Url: #{request.url}"
      end
      response = request.run
      Typhoeus.get(config[:url], followlocation: true)
      if config[:debug]
        puts "[DEBUG] Response HTTP Code: #{response.response_code}"
        puts "[DEBUG] Response Return Code: #{response.return_code}"
      end
    rescue TyphoeusError
      critical "Something went wrong\n Request Options: #{request.options}\n Request Base Url: #{request.base_url}\n Request Full Url: #{request.url}"
    end
    output "#{config[:scheme]}.time_total", response.total_time
    output "#{config[:scheme]}.time_namelookup", response.namelookup_time
    output "#{config[:scheme]}.time_connect", response.connect_time
    output "#{config[:scheme]}.time_pretransfer", response.pretransfer_time
    output "#{config[:scheme]}.time_redirect", response.redirect_time
    output "#{config[:scheme]}.time_starttransfer", response.starttransfer_time
    output "#{config[:scheme]}.http_code", response.response_code
    if response.response_code == 0
      critical
    end

    critical if config[:http_response_error] && response.response_code >= 400
    warning if config[:http_redirect_warning] && response.response_code.between?(300, 399)
    ok
  end
end
