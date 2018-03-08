#!/usr/bin/env ruby
# frozen_string_literal: false

#
#   check-http-cors
#
# DESCRIPTION:
#   Takes either a URL or a combination of host/path/query/port/ssl, and checks
#   for valid JSON output in the response. Can also optionally validate simple
#   string key/value pairs.
#
# OUTPUT:
#   plain text
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: json
#   gem: net/http
#
# USAGE:
#   #YELLOW
#
# EXAMPLE:
#   # simple key access
#     $ ruby plugins/http/check-http-json.rb -u https://example.com/cors_resource -O "Origin:http://dummy"
#
# NOTES:
#   Based on Check HTTP by Sonian Inc.
#
# LICENSE:
#   Copyright 2015 Alexander Paz <alexjpaz@gmail.com>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/check/cli'
require 'json'
require 'net/http'
require 'net/https'

class CheckCORS < Sensu::Plugin::Check::CLI
  option :url, short: '-u URL'
  option :host, short: '-h HOST'
  option :path, short: '-p PATH'
  option :query, short: '-q QUERY'
  option :port, short: '-P PORT', proc: proc(&:to_i)
  option :header, short: '-H HEADER', long: '--header HEADER'
  option :ssl, short: '-s', boolean: true, default: false
  option :insecure, short: '-k', boolean: true, default: false
  option :user, short: '-U', long: '--username USER'
  option :password, short: '-a', long: '--password PASS'
  option :cert, short: '-c FILE'
  option :cacert, short: '-C FILE'
  option :timeout, short: '-t SECS', proc: proc(&:to_i), default: 15
  option :key, short: '-K KEY', long: '--key KEY'
  option :value, short: '-v VALUE', long: '--value VALUE'

  def run
    if config[:url]
      uri = URI.parse(config[:url])
      config[:host] = uri.host
      config[:path] = uri.path
      config[:query] = uri.query
      config[:port] = uri.port
      config[:ssl] = uri.scheme == 'https'
    else
      # #YELLOW
      unless config[:host] && config[:path]
        unknown 'No URL specified'
      end
      config[:port] ||= config[:ssl] ? 443 : 80
    end

    begin
      timeout(config[:timeout]) do
        acquire_resource
      end
    rescue Timeout::Error
      critical 'Connection timed out'
    rescue StandardError => e
      critical "Connection error: #{e.message}"
    end
  end

  def cors?(res)
    headers = {}

    if config[:header]
      config[:header].split(',').each do |header|
        h, v = header.split(':', 2)
        headers[h] = v.strip
      end
    end

    res['Access-Control-Allow-Origin'] == headers['Origin']
  end

  def acquire_resource
    res = request_http

    case res.code
    when /^2/
      if cors?(res)
        ok 'Request has matching CORS headers'
      else
        critical 'Response does not have valid CORS headers'
      end
    else
      critical res.code
    end
  end

  def request_http
    http = Net::HTTP.new(config[:host], config[:port])

    if config[:ssl]
      http.use_ssl = true
      if config[:cert]
        cert_data = File.read(config[:cert])
        http.cert = OpenSSL::X509::Certificate.new(cert_data)
        http.key = OpenSSL::PKey::RSA.new(cert_data, nil)
      end
      http.ca_file = config[:cacert] if config[:cacert]
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE if config[:insecure]
    end

    req = Net::HTTP::Get.new([config[:path], config[:query]].compact.join('?'))
    unless config[:user].nil? && config[:password].nil?
      req.basic_auth config[:user], config[:password]
    end

    if config[:header]
      config[:header].split(',').each do |header|
        h, v = header.split(':', 2)
        req[h] = v.strip
      end
    end

    http.request(req)
  end
end
