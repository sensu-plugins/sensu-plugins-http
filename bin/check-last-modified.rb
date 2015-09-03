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
require 'aws-sdk-core'
require 'json'
require 'sensu-plugins-http'

#
# Checks the last modified time of a file to verify it has been updated with a
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

  option :follow_redirects,
          short: '-r FOLLOW_REDIRECTS',
          long: '--redirect FOLLOW_REDIRECTS',
          proc: proc(&:to_i),
          default: 0,
          description: 'Follow first <N> redirects'

  option :follow_redirects_with_get,
          short: '-g GET_REDIRECTS',
          long: '--get-redirects GET_REDIRECTS',
          proc: proc(&:to_i),
          default: 0,
          description: 'Follow first <N> redirects with GET requests'

  def follow_uri(uri, total_redirects, get_redirects)
    location = URI(uri)
    http = Net::HTTP.new(location.host, location.port)
    if get_redirects > 0
      request = Net::HTTP::Get.new(location.request_uri)
    else
      request = Net::HTTP::Head.new(location.request_uri)
    end

    if config[:user] and config[:password] and total_redirects == config[:follow_redirects]
      http.use_ssl = true
      request.basic_auth(config[:user], config[:password])
    end

    response = http.request(request)

    if total_redirects > 0
      case response
      when Net::HTTPSuccess     then response
      when Net::HTTPRedirection then follow_uri(response['location'], total_redirects - 1, get_redirects - 1)
      else
        critical 'Http Error'
      end
    else
      case response
      when Net::HTTPSuccess     then response
      else
        critical 'Http Error'
      end
    end
  end

  def run
    url = config[:url]
    threshold = config[:threshold]

    #Validate arguments
    if not url
      unknown "No URL specified"
    end

    if not threshold
      unknown "No threshold specified"
    end

    response = follow_uri(url, config[:follow_redirects], config[:follow_redirects_with_get])

    #Build a request from user options and then request it
    if response.header['last-modified'] == nil
      critical 'Http Error'
    end

    #Get timestamp of file and local timestamp and compare (Both in UTC)
    file_stamp = Time.parse(response.header['last-modified']).getgm
    local_stamp = Time.now.getgm

    if (local_stamp - file_stamp).to_i <= threshold.to_i
      ok 'Last modified time OK'
    else
      critical 'Last modified time greater than threshold'
    end

  end
end
