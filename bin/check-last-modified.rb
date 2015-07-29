#! /usr/bin/env ruby
#
#   check-fleet-units
#
# DESCRIPTION:
#
# OUTPUT:
#   plain text
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#
# USAGE:
#
# NOTES:
#
# LICENSE:
#   Barry Martin <nyxcharon@gmail.com>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#
require 'sensu-plugin/check/cli'
require 'net/https'
require 'time'

#
# Checks the last modified time of a file to verify it has been updated within a
# specified threshold.
#
class CheckLastModified < Sensu::Plugin::Check::CLI
  option :url,
         short: '-u URL',
         long: '--url URL',
         description: 'The URL of the file to be checked'

  option :user,
         short: '-U USER',
         long: '--username USER',
         description: 'A username to connect as'

  option :password,
         short: '-a PASS',
         long: '--password PASS',
         description: 'A password to use for the username'

  option :threshold,
         short: '-t TIME',
         long: '--time TIME',
         description: 'The time in seconds the file should be updated by'

  def run
    cli = CheckLastModified.new
    cli.parse_options
    url = cli.config[:url]
    threshold = cli.config[:threshold]

    # Validate arguments
    unless url
      unknown 'No URL specified'
    end

    unless threshold
      unknown 'No threshold specified'
    end

    # Build a request from user options and then request it
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Head.new(uri.request_uri)

    if cli.config[:user] && cli.config[:password]
      http.use_ssl = true
      request.basic_auth(cli.config[:user], cli.config[:password])
    end

    response = http.request(request)

    if response.header['last-modified'].nil?
      critical 'Http Error'
    end

    # Get timestamp of file and local timestamp and compare (Both in UTC)
    file_stamp = Time.parse(response.header['last-modified']).getgm
    local_stamp = Time.now.getgm

    if (local_stamp - file_stamp).to_i <= threshold.to_i
      ok 'Last modified time OK'
    else
      critical 'Last modified time greater than threshold'
    end
  end
end
