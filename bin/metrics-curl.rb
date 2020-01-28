#!/usr/bin/env ruby
# frozen_string_literal: false

#
#   metrics-curl
#
# DESCRIPTION:
#   Simple wrapper around curl for getting timing stats from the various phases
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
#
# USAGE:
#   #YELLOW
#
# NOTES:
#   Based on: http://dev.nuclearrooster.com/2009/12/07/quick-download-benchmarks-with-curl/
#   by Nick Stielau.
#
# LICENSE:
#   Copyright 2012 Joe Miller
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#
require 'socket'
require 'English'
require 'sensu-plugin/metric/cli'

#
# Curl Metrics
#
class CurlMetrics < Sensu::Plugin::Metric::CLI::Graphite
  option :url,
         short: '-u URL',
         long: '--url URL',
         description: 'valid cUrl url to connect',
         default: 'http://127.0.0.1:80/'

  option :curl_args,
         short: '-a "CURL ARGS"',
         long: '--curl_args "CURL ARGS"',
         description: 'Additional arguments to pass to curl',
         default: ''

  option :scheme,
         description: 'Metric naming scheme, text to prepend to metric',
         short: '-s SCHEME',
         long: '--scheme SCHEME',
         required: true,
         default: "#{Socket.gethostname}.curl_timings"

  def run
    `which curl > /dev/null 2>&1`
    unless $CHILD_STATUS == 0
      critical 'CRITICAL: curl executable not found in PATH on this system.'\
               ' If curl cannot be installed, consider using metrics_libcurl.rb instead.'
    end

    cmd = "LC_NUMERIC=C curl --silent --output /dev/null #{config[:curl_args]} "
    cmd += '-w "%{time_total},%{time_namelookup},%{time_connect},%{time_pretransfer},%{time_redirect},%{time_starttransfer},%{http_code}" '
    cmd += config[:url]
    output = `#{cmd}`

    (time_total, time_namelookup, time_connect, time_pretransfer, time_redirect, time_starttransfer, http_code) = output.split(',')
    output "#{config[:scheme]}.time_total", time_total
    output "#{config[:scheme]}.time_namelookup", time_namelookup
    output "#{config[:scheme]}.time_connect", time_connect
    output "#{config[:scheme]}.time_pretransfer", time_pretransfer
    output "#{config[:scheme]}.time_redirect", time_redirect
    output "#{config[:scheme]}.time_starttransfer", time_starttransfer
    output "#{config[:scheme]}.http_code", http_code

    if $CHILD_STATUS.to_i == 0
      ok
    else
      warning
    end
  end
end
